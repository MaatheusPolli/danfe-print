unit App.Bootstrap;

{ Decide entre modo GUI e modo CLI a partir dos parametros de linha de comando. }

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

type
  TAppBootstrap = class
  public
    class function IsCliMode: Boolean;
    class function Run: Integer;
  end;

implementation

uses
  SysUtils, App.Container, Cli.Runner;

class function TAppBootstrap.IsCliMode: Boolean;
begin
  Result := ParamCount > 0;
end;

{ Coleta os argumentos (sem o nome do executavel) em um array dinamico. }
function ColetarArgs: TArray<string>;
var
  I: Integer;
begin
  SetLength(Result, ParamCount);
  for I := 1 to ParamCount do
    Result[I - 1] := ParamStr(I);
end;

class function TAppBootstrap.Run: Integer;
var
  Runner: TCliRunner;
  LogDir: string;
begin
  { Enquanto a GUI nao existe, sem argumentos apenas informa o uso. }
  LogDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'logs';
  Runner := TAppContainer.CriarRunner(LogDir);
  try
    if IsCliMode then
      Result := Runner.Run(ColetarArgs)
    else
      Result := Runner.Run(['--help']);
  finally
    Runner.Free;
  end;
end;

end.
