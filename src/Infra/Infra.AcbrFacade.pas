unit Infra.AcbrFacade;

{ Unica unidade que conhece a geracao de PDF do DANFE.

  Dois caminhos, selecionados pela diretiva de compilacao USE_ACBR:

  - Com USE_ACBR definido: usa o DANFE oficial do ACBr (TACBrNFeDANFEFPDF),
    que produz o layout fiscal padrao. Requer o ACBr no caminho de unidades
    (IDE Delphi ou Lazarus com os pacotes do ACBr).

  - Sem USE_ACBR (padrao, compila em FPC puro / linha de comando): usa a
    biblioteca FPDF-Pascal diretamente para gerar um PDF legivel com os dados
    essenciais da nota. Nenhuma dependencia alem do FPDF-Pascal.

  Em ambos os casos a saida e um arquivo PDF e o resultado e um TDanfeResult;
  o restante do sistema conhece apenas IDanfeGenerator. }

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

uses
  Domain.Danfe, Domain.Interfaces;

{ Fabrica o gerador concreto adequado ao ambiente de compilacao. }
function CriarGeradorDanfe: IDanfeGenerator;

implementation

uses
  SysUtils, Classes, Domain.Errors,
{$IFDEF USE_ACBR}
  ACBrNFe, ACBrNFeDANFEClass, ACBrNFeDANFEFPDF;
{$ELSE}
  fpdf;
{$ENDIF}

{ Helpers comuns de formatacao (independentes do backend). }

function TituloDoc(AModelo: TModeloDocumento): string;
begin
  case AModelo of
    mdNFCe: Result := 'DANFE NFC-e';
  else
    Result := 'DANFE';
  end;
end;

function ModeloToStr(AModelo: TModeloDocumento): string;
begin
  case AModelo of
    mdNFe:  Result := 'NF-e (modelo 55)';
    mdNFCe: Result := 'NFC-e (modelo 65)';
  else
    Result := 'desconhecido';
  end;
end;

function SituacaoStr(AAutorizada: Boolean): string;
begin
  if AAutorizada then
    Result := 'Autorizada'
  else
    Result := 'Sem protocolo (SEM VALOR FISCAL)';
end;

{ Formata a chave de 44 digitos em grupos de 4 para leitura. }
function FormatarChave(const AChave: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(AChave) do
  begin
    if (I > 1) and (((I - 1) mod 4) = 0) then
      Result := Result + ' ';
    Result := Result + AChave[I];
  end;
end;

{$IFDEF USE_ACBR}

{ ===================== Backend ACBr (DANFE oficial) ===================== }

type
  TAcbrDanfeGenerator = class(TInterfacedObject, IDanfeGenerator)
  public
    function Gerar(const AXmlFile: string; const ANota: TNotaInfo;
      const AOutputFile: string; const AOptions: TDanfeOptions): TDanfeResult;
  end;

function TAcbrDanfeGenerator.Gerar(const AXmlFile: string; const ANota: TNotaInfo;
  const AOutputFile: string; const AOptions: TDanfeOptions): TDanfeResult;
var
  NFe: TACBrNFe;
  Danfe: TACBrNFeDANFEFPDF;
begin
  try
    NFe := TACBrNFe.Create(nil);
    try
      Danfe := TACBrNFeDANFEFPDF.Create(nil);
      try
        NFe.DANFE := Danfe;
        if AOptions.Orientacao = doPaisagem then
          Danfe.ImprimirDANFEPaisagem := True
        else
          Danfe.ImprimirDANFEPaisagem := False;
        if (AOptions.LogoFile <> '') and FileExists(AOptions.LogoFile) then
          Danfe.Logo := AOptions.LogoFile;
        Danfe.PathPDF := ExtractFilePath(AOutputFile);
        Danfe.NomeDocumento := AOutputFile;

        NFe.NotasFiscais.Clear;
        NFe.NotasFiscais.LoadFromFile(AXmlFile);
        NFe.NotasFiscais.ImprimirPDF;
      finally
        Danfe.Free;
      end;
    finally
      NFe.Free;
    end;
    Result := TDanfeResult.Ok(AXmlFile, AOutputFile);
  except
    on E: Exception do
      Result := TDanfeResult.Fail(AXmlFile, Format(SErroGeracaoPdf, [E.Message]));
  end;
end;

function CriarGeradorDanfe: IDanfeGenerator;
begin
  Result := TAcbrDanfeGenerator.Create;
end;

{$ELSE}

{ ===================== Backend FPDF-Pascal (portavel) ===================== }

type
  TFpdfDanfeGenerator = class(TInterfacedObject, IDanfeGenerator)
  private
    procedure LinhaCampo(APdf: TFPDF; const ALabel, AValue: string);
  public
    function Gerar(const AXmlFile: string; const ANota: TNotaInfo;
      const AOutputFile: string; const AOptions: TDanfeOptions): TDanfeResult;
  end;

procedure TFpdfDanfeGenerator.LinhaCampo(APdf: TFPDF; const ALabel, AValue: string);
begin
  APdf.SetFont('Arial', 'B', 10);
  APdf.Cell(45, 7, ALabel + ':', '0', 0, 'L');
  APdf.SetFont('Arial', '', 10);
  APdf.MultiCell(0, 7, AValue, '0', 'L');
end;

function TFpdfDanfeGenerator.Gerar(const AXmlFile: string; const ANota: TNotaInfo;
  const AOutputFile: string; const AOptions: TDanfeOptions): TDanfeResult;
var
  Pdf: TFPDF;
  Orient: TFPDFOrientation;
begin
  try
    if AOptions.Orientacao = doPaisagem then
      Orient := poLandscape
    else
      Orient := poPortrait;

    Pdf := TFPDF.Create(Orient, puMM, pfA4);
    try
      Pdf.SetTitle('DANFE ' + ANota.Chave);
      Pdf.SetAutoPageBreak(True, 10);
      Pdf.AddPage;

      { Logo opcional; um logo invalido nao impede a geracao. }
      if (AOptions.LogoFile <> '') and FileExists(AOptions.LogoFile) then
      begin
        try
          Pdf.Image(AOptions.LogoFile, Pdf.GetX, Pdf.GetY, 30);
          Pdf.Ln(2);
        except
          { ignora logo invalido }
        end;
      end;

      { Cabecalho. }
      Pdf.SetFont('Arial', 'B', 16);
      Pdf.Cell(0, 10, TituloDoc(ANota.Modelo), '0', 1, 'C');
      Pdf.SetFont('Arial', '', 10);
      Pdf.Cell(0, 6, 'Documento Auxiliar da Nota Fiscal Eletronica', '0', 1, 'C');
      Pdf.Ln(4);

      { Quadro de dados essenciais. }
      LinhaCampo(Pdf, 'Modelo', ModeloToStr(ANota.Modelo));
      LinhaCampo(Pdf, 'Numero', ANota.Numero);
      LinhaCampo(Pdf, 'Serie', ANota.Serie);
      LinhaCampo(Pdf, 'CNPJ emitente', ANota.CnpjEmitente);
      LinhaCampo(Pdf, 'Chave de acesso', FormatarChave(ANota.Chave));
      LinhaCampo(Pdf, 'Situacao', SituacaoStr(ANota.Autorizada));

      { Marca para notas sem protocolo. }
      if not ANota.Autorizada then
      begin
        Pdf.Ln(10);
        Pdf.SetTextColor(200, 0, 0);
        Pdf.SetDrawColor(200, 0, 0);
        Pdf.SetFont('Arial', 'B', 26);
        Pdf.Cell(0, 20, 'SEM VALOR FISCAL', '1', 1, 'C');
        Pdf.SetTextColor(0, 0, 0);
        Pdf.SetDrawColor(0, 0, 0);
      end;

      Pdf.SaveToFile(AOutputFile);
    finally
      Pdf.Free;
    end;
    Result := TDanfeResult.Ok(AXmlFile, AOutputFile);
  except
    on E: Exception do
      Result := TDanfeResult.Fail(AXmlFile, Format(SErroGeracaoPdf, [E.Message]));
  end;
end;

function CriarGeradorDanfe: IDanfeGenerator;
begin
  Result := TFpdfDanfeGenerator.Create;
end;

{$ENDIF}

end.
