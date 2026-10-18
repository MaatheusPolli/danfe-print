unit Service.Batch;

{ Processa uma pasta inteira (RF06): um PDF por XML e relatorio.csv com
  sucesso/erro por arquivo. Um erro isolado nunca aborta o lote. }

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

uses
  Domain.Danfe, Domain.Interfaces;

const
  NOME_RELATORIO = 'relatorio.csv';

type
  TBatchProcessor = class(TInterfacedObject, IBatchProcessor)
  private
    FService: IDanfeService;
    FLog: ILogService;
    procedure GravarRelatorio(const AFile: string; const AResultados: TArray<TDanfeResult>);
  public
    constructor Create(const AService: IDanfeService; const ALog: ILogService);
    function GerarLote(const AInputDir, AOutputDir: string;
      const AOptions: TDanfeOptions): TArray<TDanfeResult>;
  end;

function CsvCampo(const AValor: string): string;

implementation

uses
  SysUtils, Classes, Domain.Errors, Service.Danfe, Infra.FileSystem;

function CsvCampo(const AValor: string): string;
begin
  // Separador ';' (padrao do Excel pt-BR); aspas sempre, duplicando as internas.
  Result := '"' + StringReplace(AValor, '"', '""', [rfReplaceAll]) + '"';
end;

constructor TBatchProcessor.Create(const AService: IDanfeService; const ALog: ILogService);
begin
  inherited Create;
  FService := AService;
  FLog := ALog;
end;

procedure TBatchProcessor.GravarRelatorio(const AFile: string;
  const AResultados: TArray<TDanfeResult>);
var
  SB: TStringBuilder;
  R: TDanfeResult;
  Status: string;
begin
  SB := TStringBuilder.Create;
  try
    SB.Append('arquivo;status;pdf;mensagem').Append(sLineBreak);
    for R in AResultados do
    begin
      if R.Success then
        Status := 'OK'
      else
        Status := 'ERRO';
      SB.Append(CsvCampo(ExtractFileName(R.XmlFile))).Append(';')
        .Append(CsvCampo(Status)).Append(';')
        .Append(CsvCampo(R.OutputFile)).Append(';')
        .Append(CsvCampo(R.ErrorMessage)).Append(sLineBreak);
    end;
    GravarTextoUtf8(AFile, SB.ToString);
  finally
    SB.Free;
  end;
end;

function TBatchProcessor.GerarLote(const AInputDir, AOutputDir: string;
  const AOptions: TDanfeOptions): TArray<TDanfeResult>;
var
  Arquivos: TArray<string>;
  OutDir: string;
  I: Integer;
begin
  Result := nil;
  if not DirectoryExists(AInputDir) then
  begin
    FLog.Error(Format(SPastaNaoEncontrada, [AInputDir]));
    Exit([TDanfeResult.Fail(AInputDir, Format(SPastaNaoEncontrada, [AInputDir]))]);
  end;

  OutDir := AOutputDir;
  if OutDir = '' then
    OutDir := AInputDir;
  ForceDirectories(OutDir);

  Arquivos := ListarXmls(AInputDir);
  if Length(Arquivos) = 0 then
    FLog.Error(Format(SNenhumXml, [AInputDir]));

  SetLength(Result, Length(Arquivos));
  for I := 0 to High(Arquivos) do
    try
      Result[I] := FService.GerarPdf(Arquivos[I], OutputPadrao(Arquivos[I], OutDir), AOptions);
    except
      on E: Exception do
        Result[I] := TDanfeResult.Fail(Arquivos[I], Format(SErroInesperado, [E.Message]));
    end;

  try
    GravarRelatorio(IncludeTrailingPathDelimiter(OutDir) + NOME_RELATORIO, Result);
  except
    on E: Exception do
      FLog.Error(Format(SErroGravarRelatorio, [E.Message]));
  end;
end;

end.
