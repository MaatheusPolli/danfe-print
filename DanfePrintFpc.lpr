program DanfePrintFpc;

{ Entry-point console para builds com Free Pascal (linha de comando, sem VCL).
  O DanfePrint.dpr (modo GUI, com o recurso .res) permanece alvo do Delphi/IDE.
  Ambos chamam o mesmo TAppBootstrap.Run. }

{$mode delphi}{$H+}
{$APPTYPE CONSOLE}

uses
  {$IFDEF MSWINDOWS}Windows,{$ENDIF}
  App.Bootstrap;

begin
  { Mensagens acentuadas (CP1252) saem corretas no console do Windows. }
  {$IFDEF MSWINDOWS}SetConsoleOutputCP(1252);{$ENDIF}
  ExitCode := TAppBootstrap.Run;
end.
