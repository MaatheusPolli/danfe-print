program DanfePrintTests;

{ Runner DUnitX (Delphi). Equivalente ao DanfePrintTestsFpc.lpr (fpcunit).
  Uso: bin\DanfePrintTests.exe --exclude:integration
  Testes de integracao (geram PDF real) ficam na categoria "integration". }

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  DUnitX.TestFramework,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  Dx.XmlLoader in 'dunitx\Dx.XmlLoader.pas',
  Dx.DanfeService in 'dunitx\Dx.DanfeService.pas',
  Dx.CliParser in 'dunitx\Dx.CliParser.pas',
  Dx.Batch in 'dunitx\Dx.Batch.pas',
  Dx.Config in 'dunitx\Dx.Config.pas',
  Dx.AcbrFacade in 'dunitx\Dx.AcbrFacade.pas',
  Dx.UiFormat in 'dunitx\Dx.UiFormat.pas',
  Tests.Helpers in 'Tests.Helpers.pas',
  Tests.Mocks in 'Tests.Mocks.pas';

var
  Runner: ITestRunner;
  Results: IRunResults;
  Logger: ITestLogger;
  NUnit: ITestLogger;
begin
  try
    TDUnitX.CheckCommandLine;
    Runner := TDUnitX.CreateRunner;
    Runner.UseRTTI := True;
    Logger := TDUnitXConsoleLogger.Create(False);
    Runner.AddLogger(Logger);
    NUnit := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    Runner.AddLogger(NUnit);
    Results := Runner.Execute;
    if not Results.AllPassed then
      System.ExitCode := 1;
  except
    on E: Exception do
    begin
      System.Writeln(E.ClassName, ': ', E.Message);
      System.ExitCode := 2;
    end;
  end;
end.
