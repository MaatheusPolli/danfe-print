unit Tests.Helpers;

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

function FixturePath(const AName: string): string;
function TempDir(const ASub: string): string;
// Converte barras invertidas dos literais de teste para o separador do sistema.
function P(const S: string): string;

implementation

uses
  SysUtils;

function P(const S: string): string;
begin
  Result := StringReplace(S, '\', PathDelim, [rfReplaceAll]);
end;

function FixturePath(const AName: string): string;
begin
  // Executavel de testes fica em bin/; fixtures em tests/fixtures/.
  Result := ExpandFileName(ExtractFilePath(ParamStr(0)) + P('..\tests\fixtures\') + AName);
end;

function TempDir(const ASub: string): string;
begin
  Result := IncludeTrailingPathDelimiter(GetTempDir) + 'danfeprint-tests' + PathDelim + ASub + PathDelim;
  ForceDirectories(Result);
end;

end.
