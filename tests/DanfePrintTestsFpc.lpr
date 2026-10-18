program DanfePrintTestsFpc;

{ Runner fpcunit (Free Pascal). A suite DUnitX para Delphi sera adicionada
  junto com as partes que dependem do Delphi. }

{$mode delphi}{$H+}

uses
  Classes, consoletestrunner,
  Tests.Helpers, Tests.Mocks, Tests.XmlLoader, Tests.DanfeService, Tests.CliParser, Tests.Batch, Tests.Config,
  Tests.AcbrFacade;

var
  App: TTestRunner;
begin
  DefaultFormat := fPlain;
  DefaultRunAllTests := True;
  App := TTestRunner.Create(nil);
  try
    App.Initialize;
    App.Run;
  finally
    App.Free;
  end;
end.
