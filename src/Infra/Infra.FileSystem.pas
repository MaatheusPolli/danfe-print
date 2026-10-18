unit Infra.FileSystem;

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

{ Arquivos *.xml da pasta (nao recursivo), com caminho completo, em ordem alfabetica. }
function ListarXmls(const ADir: string): TArray<string>;

{ Grava texto em UTF-8 com BOM (Excel abre acentos corretamente). }
procedure GravarTextoUtf8(const AFile, AText: string);

implementation

uses
  SysUtils, Classes;

function ListarXmls(const ADir: string): TArray<string>;
var
  SR: TSearchRec;
  Lista: TStringList;
  Dir: string;
  I: Integer;
begin
  Result := nil;
  Dir := IncludeTrailingPathDelimiter(ADir);
  Lista := TStringList.Create;
  try
    if FindFirst(Dir + '*.xml', faAnyFile, SR) = 0 then
    try
      repeat
        if (SR.Attr and faDirectory) = 0 then
          Lista.Add(Dir + SR.Name);
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
    Lista.Sort;
    SetLength(Result, Lista.Count);
    for I := 0 to Lista.Count - 1 do
      Result[I] := Lista[I];
  finally
    Lista.Free;
  end;
end;

procedure GravarTextoUtf8(const AFile, AText: string);
const
  BOM: array[0..2] of Byte = ($EF, $BB, $BF);
var
  FS: TFileStream;
  Bytes: TBytes;
begin
{$IFDEF FPC}
  // No FPC o string e AnsiString com os literais UTF-8 do fonte: grava os bytes como estao.
  SetLength(Bytes, Length(AText));
  if Length(AText) > 0 then
    Move(AText[1], Bytes[0], Length(AText));
{$ELSE}
  Bytes := TEncoding.UTF8.GetBytes(AText);
{$ENDIF}
  FS := TFileStream.Create(AFile, fmCreate);
  try
    FS.WriteBuffer(BOM, SizeOf(BOM));
    if Length(Bytes) > 0 then
      FS.WriteBuffer(Bytes[0], Length(Bytes));
  finally
    FS.Free;
  end;
end;

end.
