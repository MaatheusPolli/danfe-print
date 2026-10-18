unit Cli.Runner;

{ Executa a acao pedida na linha de comando e devolve o exit code. }

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

uses
  Domain.Interfaces, Cli.Parser;

type
  { Abstrai stdout/stderr para permitir testes. }
  ICliConsole = interface
    ['{8F2A4C6E-1B3D-4E5F-9A7C-3D5E7F9B1C66}']
    procedure Out(const AText: string);
    procedure Err(const AText: string);
  end;

  TStdConsole = class(TInterfacedObject, ICliConsole)
  public
    procedure Out(const AText: string);
    procedure Err(const AText: string);
  end;

  TCliRunner = class
  private
    FService: IDanfeService;
    FBatch: IBatchProcessor;
    FConsole: ICliConsole;
    FQuiet: Boolean;
    procedure Info(const AText: string);
    function RodarArquivo(const AOptions: TCliOptions): Integer;
    function RodarLote(const AOptions: TCliOptions): Integer;
  public
    constructor Create(const AService: IDanfeService; const ABatch: IBatchProcessor;
      const AConsole: ICliConsole);
    function Run(const AArgs: array of string): Integer;
  end;

implementation

uses
  SysUtils, Domain.Danfe, Domain.Errors;

resourcestring
  SGerado = 'Gerado: %s';
  SLoteResumo = 'Lote concluído: %d sucesso(s), %d erro(s)';
  SErroUso = 'Erro: %s';
  SUseHelp = 'Use --help para ver as opções.';

procedure TStdConsole.Out(const AText: string);
begin
  WriteLn(Output, AText);
end;

procedure TStdConsole.Err(const AText: string);
begin
  WriteLn(ErrOutput, AText);
end;

constructor TCliRunner.Create(const AService: IDanfeService;
  const ABatch: IBatchProcessor; const AConsole: ICliConsole);
begin
  inherited Create;
  FService := AService;
  FBatch := ABatch;
  FConsole := AConsole;
end;

procedure TCliRunner.Info(const AText: string);
begin
  if not FQuiet then
    FConsole.Out(AText);
end;

function TCliRunner.RodarArquivo(const AOptions: TCliOptions): Integer;
var
  R: TDanfeResult;
begin
  R := FService.GerarPdf(AOptions.InFile, AOptions.OutFile, AOptions.Danfe);
  if R.Success then
  begin
    Info(Format(SGerado, [R.OutputFile]));
    Result := EXIT_OK;
  end
  else
  begin
    FConsole.Err(R.ErrorMessage);
    Result := EXIT_ERRO_PROCESSAMENTO;
  end;
end;

function TCliRunner.RodarLote(const AOptions: TCliOptions): Integer;
var
  Resultados: TArray<TDanfeResult>;
  R: TDanfeResult;
  Ok, Falhas: Integer;
begin
  Resultados := FBatch.GerarLote(AOptions.InDir, AOptions.OutDir, AOptions.Danfe);
  Ok := 0;
  Falhas := 0;
  for R in Resultados do
    if R.Success then
      Inc(Ok)
    else
    begin
      Inc(Falhas);
      FConsole.Err(ExtractFileName(R.XmlFile) + ': ' + R.ErrorMessage);
    end;
  Info(Format(SLoteResumo, [Ok, Falhas]));
  if (Falhas > 0) or (Length(Resultados) = 0) then
    Result := EXIT_ERRO_PROCESSAMENTO
  else
    Result := EXIT_OK;
end;

function TCliRunner.Run(const AArgs: array of string): Integer;
var
  P: TCliParseResult;
begin
  P := TCliParser.Parse(AArgs);
  if not P.Success then
  begin
    FConsole.Err(Format(SErroUso, [P.ErrorMessage]));
    FConsole.Err(SUseHelp);
    Exit(EXIT_ERRO_USO);
  end;

  FQuiet := P.Options.Quiet;
  try
    case P.Options.Acao of
      caAjuda:
        begin
          FConsole.Out(TCliParser.TextoAjuda);
          Result := EXIT_OK;
        end;
      caLote:
        Result := RodarLote(P.Options);
    else
      Result := RodarArquivo(P.Options);
    end;
  except
    on E: Exception do
    begin
      FConsole.Err(Format(SErroInesperado, [E.Message]));
      Result := EXIT_ERRO_PROCESSAMENTO;
    end;
  end;
end;

end.
