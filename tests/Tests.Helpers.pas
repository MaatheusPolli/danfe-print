unit Tests.Helpers;

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

function FixturePath(const AName: string): string;
function TempDir(const ASub: string): string;

implementation

uses
  SysUtils;

function FixturePath(const AName: string): string;
begin
  // Executavel de testes fica em bin\; fixtures em tests\fixtures\.
  Result := ExpandFileName(ExtractFilePath(ParamStr(0)) + '..\tests\fixtures\' + AName);
end;

function TempDir(const ASub: string): string;
begin
  Result := IncludeTrailingPathDelimiter(GetTempDir) + 'danfeprint-tests\' + ASub + '\';
  ForceDirectories(Result);
end;

end.
