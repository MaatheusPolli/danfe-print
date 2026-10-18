unit Domain.Danfe;

{ Tipos de dominio compartilhados por GUI, CLI e servicos. }

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

type
  TDanfeOrientacao = (doRetrato, doPaisagem);

  TModeloDocumento = (mdDesconhecido, mdNFe, mdNFCe);

  TDanfeOptions = record
    Orientacao: TDanfeOrientacao;
    LogoFile: string;
    class function Default: TDanfeOptions; static;
  end;

  { Dados minimos extraidos do XML e necessarios para gerar o DANFE. }
  TNotaInfo = record
    Chave: string;
    Modelo: TModeloDocumento;
    Numero: string;
    Serie: string;
    CnpjEmitente: string;
    Autorizada: Boolean;  // True quando ha nfeProc/protNFe; False = "SEM VALOR FISCAL"
  end;

  TXmlLoadResult = record
    Success: Boolean;
    Nota: TNotaInfo;
    ErrorMessage: string;
    class function Ok(const ANota: TNotaInfo): TXmlLoadResult; static;
    class function Fail(const AMessage: string): TXmlLoadResult; static;
  end;

  TDanfeResult = record
    Success: Boolean;
    XmlFile: string;
    OutputFile: string;
    ErrorMessage: string;
    class function Ok(const AXmlFile, AOutputFile: string): TDanfeResult; static;
    class function Fail(const AXmlFile, AMessage: string): TDanfeResult; static;
  end;

function OrientacaoToStr(AValue: TDanfeOrientacao): string;
function TryStrToOrientacao(const AText: string; out AValue: TDanfeOrientacao): Boolean;

implementation

uses
  SysUtils;

class function TDanfeOptions.Default: TDanfeOptions;
begin
  Result.Orientacao := doRetrato;
  Result.LogoFile := '';
end;

class function TXmlLoadResult.Ok(const ANota: TNotaInfo): TXmlLoadResult;
begin
  Result.Success := True;
  Result.Nota := ANota;
  Result.ErrorMessage := '';
end;

class function TXmlLoadResult.Fail(const AMessage: string): TXmlLoadResult;
begin
  Result := Default(TXmlLoadResult);
  Result.Success := False;
  Result.ErrorMessage := AMessage;
end;

class function TDanfeResult.Ok(const AXmlFile, AOutputFile: string): TDanfeResult;
begin
  Result.Success := True;
  Result.XmlFile := AXmlFile;
  Result.OutputFile := AOutputFile;
  Result.ErrorMessage := '';
end;

class function TDanfeResult.Fail(const AXmlFile, AMessage: string): TDanfeResult;
begin
  Result.Success := False;
  Result.XmlFile := AXmlFile;
  Result.OutputFile := '';
  Result.ErrorMessage := AMessage;
end;

function OrientacaoToStr(AValue: TDanfeOrientacao): string;
begin
  if AValue = doPaisagem then
    Result := 'paisagem'
  else
    Result := 'retrato';
end;

function TryStrToOrientacao(const AText: string; out AValue: TDanfeOrientacao): Boolean;
var
  S: string;
begin
  S := LowerCase(Trim(AText));
  Result := True;
  if S = 'retrato' then
    AValue := doRetrato
  else if S = 'paisagem' then
    AValue := doPaisagem
  else
    Result := False;
end;

end.
