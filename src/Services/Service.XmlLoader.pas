unit Service.XmlLoader;

{ Le e valida a estrutura minima do XML de NF-e/NFC-e (RF01, RF02). }

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

uses
  Domain.Danfe, Domain.Interfaces;

type
  TXmlLoader = class(TInterfacedObject, IXmlLoader)
  public
    function Carregar(const AXmlFile: string): TXmlLoadResult;
  end;

{ Valida 44 digitos e digito verificador (modulo 11) da chave de acesso. }
function ChaveValida(const AChave: string): Boolean;
function CalcularDVChave(const AChave43: string): Integer;
function ModeloFromCodigo(const ACodigo: string): TModeloDocumento;

implementation

uses
  SysUtils, Domain.Errors, Infra.XmlDom;

function SoDigitos(const S: string): Boolean;
var
  C: Char;
begin
  Result := S <> '';
  for C in S do
    if not CharInSet(C, ['0'..'9']) then
      Exit(False);
end;

function CalcularDVChave(const AChave43: string): Integer;
var
  I, Peso, Soma, Resto: Integer;
begin
  Soma := 0;
  Peso := 2;
  for I := Length(AChave43) downto 1 do
  begin
    Soma := Soma + (Ord(AChave43[I]) - Ord('0')) * Peso;
    Inc(Peso);
    if Peso > 9 then
      Peso := 2;
  end;
  Resto := Soma mod 11;
  if Resto < 2 then
    Result := 0
  else
    Result := 11 - Resto;
end;

function ChaveValida(const AChave: string): Boolean;
begin
  Result := (Length(AChave) = 44) and SoDigitos(AChave) and
    (CalcularDVChave(Copy(AChave, 1, 43)) = Ord(AChave[44]) - Ord('0'));
end;

function ModeloFromCodigo(const ACodigo: string): TModeloDocumento;
begin
  if ACodigo = '55' then
    Result := mdNFe
  else if ACodigo = '65' then
    Result := mdNFCe
  else
    Result := mdDesconhecido;
end;

function TXmlLoader.Carregar(const AXmlFile: string): TXmlLoadResult;
var
  Dados: TNFeXmlDados;
  Erro, Chave, ModChave: string;
  Nota: TNotaInfo;
begin
  if not FileExists(AXmlFile) then
    Exit(TXmlLoadResult.Fail(Format(SArquivoNaoEncontrado, [AXmlFile])));

  if not LerDadosNFe(AXmlFile, Dados, Erro) then
    Exit(TXmlLoadResult.Fail(Format(SXmlMalFormado, [Erro])));

  if (Dados.RootName <> 'nfeProc') and (Dados.RootName <> 'NFe') then
    Exit(TXmlLoadResult.Fail(Format(SRaizInvalida, [Dados.RootName])));

  if not Dados.HasInfNFe then
    Exit(TXmlLoadResult.Fail(SInfNFeAusente));

  if not SameText(Copy(Dados.InfNFeId, 1, 3), 'NFe') then
    Exit(TXmlLoadResult.Fail(SChaveAusente));

  Chave := Copy(Dados.InfNFeId, 4, MaxInt);
  if not ChaveValida(Chave) then
    Exit(TXmlLoadResult.Fail(Format(SChaveInvalida, [Chave])));

  ModChave := Copy(Chave, 21, 2);
  Nota := Default(TNotaInfo);
  Nota.Modelo := ModeloFromCodigo(ModChave);
  if Nota.Modelo = mdDesconhecido then
    Exit(TXmlLoadResult.Fail(Format(SModeloDesconhecido, [ModChave])));
  if (Dados.IdeMod <> '') and (Dados.IdeMod <> ModChave) then
    Exit(TXmlLoadResult.Fail(Format(SModeloDivergente, [Dados.IdeMod, ModChave])));

  Nota.Chave := Chave;
  Nota.Numero := Dados.IdeNNF;
  Nota.Serie := Dados.IdeSerie;
  Nota.CnpjEmitente := Dados.EmitCNPJ;
  // RF01: NFe sem protocolo e aceita, mas o DANFE sai "SEM VALOR FISCAL".
  Nota.Autorizada := (Dados.RootName = 'nfeProc') and Dados.HasProtNFe;
  Result := TXmlLoadResult.Ok(Nota);
end;

end.
