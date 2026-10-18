unit Service.Danfe;

{ Orquestra: carrega/valida o XML e delega a geracao ao IDanfeGenerator.
  Erros previsiveis viram TDanfeResult; excecoes inesperadas sao capturadas e logadas. }

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

uses
  Domain.Danfe, Domain.Interfaces;

type
  TDanfeService = class(TInterfacedObject, IDanfeService)
  private
    FLoader: IXmlLoader;
    FGenerator: IDanfeGenerator;
    FLog: ILogService;
  public
    constructor Create(const ALoader: IXmlLoader; const AGenerator: IDanfeGenerator;
      const ALog: ILogService);
    function GerarPdf(const AXmlFile, AOutputFile: string;
      const AOptions: TDanfeOptions): TDanfeResult;
  end;

{ Caminho padrao do PDF: mesmo nome do XML com extensao .pdf, na pasta indicada
  (ou na pasta do XML se ADir for vazio). }
function OutputPadrao(const AXmlFile, ADir: string): string;

implementation

uses
  SysUtils, Domain.Errors;

function OutputPadrao(const AXmlFile, ADir: string): string;
var
  Dir: string;
begin
  if ADir = '' then
    Dir := ExtractFilePath(AXmlFile)
  else
    Dir := IncludeTrailingPathDelimiter(ADir);
  Result := Dir + ChangeFileExt(ExtractFileName(AXmlFile), '.pdf');
end;

constructor TDanfeService.Create(const ALoader: IXmlLoader;
  const AGenerator: IDanfeGenerator; const ALog: ILogService);
begin
  inherited Create;
  FLoader := ALoader;
  FGenerator := AGenerator;
  FLog := ALog;
end;

function TDanfeService.GerarPdf(const AXmlFile, AOutputFile: string;
  const AOptions: TDanfeOptions): TDanfeResult;
var
  Load: TXmlLoadResult;
  Saida, Dir: string;
begin
  try
    Load := FLoader.Carregar(AXmlFile);
    if not Load.Success then
      Result := TDanfeResult.Fail(AXmlFile, Load.ErrorMessage)
    else
    begin
      Saida := AOutputFile;
      if Saida = '' then
        Saida := OutputPadrao(AXmlFile, '');
      Dir := ExtractFileDir(Saida);
      if Dir <> '' then
        ForceDirectories(Dir);
      Result := FGenerator.Gerar(AXmlFile, Load.Nota, Saida, AOptions);
      Result.XmlFile := AXmlFile;
    end;
  except
    on E: Exception do
      Result := TDanfeResult.Fail(AXmlFile, Format(SErroInesperado, [E.Message]));
  end;

  if Result.Success then
    FLog.Info(ExtractFileName(AXmlFile) + ' -> ' + Result.OutputFile)
  else
    FLog.Error(ExtractFileName(AXmlFile) + ': ' + Result.ErrorMessage);
end;

end.
