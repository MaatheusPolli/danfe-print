program DanfePrint;

{ Alvo Delphi/IDE. Sem argumentos abre a GUI VCL; com argumentos roda a CLI
  (mesmo TAppBootstrap.Run usado pelo DanfePrintFpc.lpr). }

uses
  Vcl.Forms,
  App.Bootstrap in 'src\App\App.Bootstrap.pas',
  App.Container in 'src\App\App.Container.pas',
  App.Config in 'src\App\App.Config.pas',
  UI.Main in 'src\UI\UI.Main.pas' {FormMain},
  UI.Batch in 'src\UI\UI.Batch.pas' {FormBatch},
  UI.Settings in 'src\UI\UI.Settings.pas' {FormSettings};

begin
  if TAppBootstrap.IsCliMode then
  begin
    ExitCode := TAppBootstrap.Run;
    Exit;
  end;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
