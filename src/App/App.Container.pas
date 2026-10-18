unit App.Container;

{ Composition root: monta as dependencias concretas (loader, generator, log,
  service, batch, runner). E o unico ponto que conhece as implementacoes ao
  mesmo tempo; GUI e CLI pedem objetos prontos aqui. }

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

uses
  Domain.Interfaces, Cli.Runner;

type
  TAppContainer = class
  public
    { Log em arquivo diario no diretorio indicado; vazio usa TNullLog. }
    class function CriarLog(const ALogDir: string): ILogService;
    class function CriarService(const ALog: ILogService): IDanfeService;
    class function CriarBatch(const AService: IDanfeService;
      const ALog: ILogService): IBatchProcessor;
    { Runner de linha de comando com stdout/stderr reais. }
    class function CriarRunner(const ALogDir: string): TCliRunner;
  end;

implementation

uses
  Service.XmlLoader, Service.Danfe, Service.Batch, Service.Log, Infra.AcbrFacade;

class function TAppContainer.CriarLog(const ALogDir: string): ILogService;
begin
  if ALogDir = '' then
    Result := TNullLog.Create
  else
    Result := TFileLog.Create(ALogDir);
end;

class function TAppContainer.CriarService(const ALog: ILogService): IDanfeService;
var
  Loader: IXmlLoader;
  Generator: IDanfeGenerator;
begin
  Loader := TXmlLoader.Create;
  Generator := CriarGeradorDanfe;
  Result := TDanfeService.Create(Loader, Generator, ALog);
end;

class function TAppContainer.CriarBatch(const AService: IDanfeService;
  const ALog: ILogService): IBatchProcessor;
begin
  Result := TBatchProcessor.Create(AService, ALog);
end;

class function TAppContainer.CriarRunner(const ALogDir: string): TCliRunner;
var
  Log: ILogService;
  Service: IDanfeService;
  Batch: IBatchProcessor;
begin
  Log := CriarLog(ALogDir);
  Service := CriarService(Log);
  Batch := CriarBatch(Service, Log);
  Result := TCliRunner.Create(Service, Batch, TStdConsole.Create);
end;

end.
