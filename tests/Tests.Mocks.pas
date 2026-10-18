unit Tests.Mocks;

{ Dublês de teste: gerador que grava um "PDF" falso e console em memória. }

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

uses
  Classes, Domain.Danfe, Domain.Interfaces, Cli.Runner;

type
  TFakeGenerator = class(TInterfacedObject, IDanfeGenerator)
  public
    Chamadas: Integer;
    UltimaNota: TNotaInfo;
    UltimasOpcoes: TDanfeOptions;
    LevantarExcecao: Boolean;
    function Gerar(const AXmlFile: string; const ANota: TNotaInfo;
      const AOutputFile: string; const AOptions: TDanfeOptions): TDanfeResult;
  end;

  TFakeService = class(TInterfacedObject, IDanfeService)
  public
    Resultado: TDanfeResult;
    UltimoXml, UltimoOut: string;
    UltimasOpcoes: TDanfeOptions;
    function GerarPdf(const AXmlFile, AOutputFile: string;
      const AOptions: TDanfeOptions): TDanfeResult;
  end;

  TFakeBatch = class(TInterfacedObject, IBatchProcessor)
  public
    Resultados: TArray<TDanfeResult>;
    UltimoIn, UltimoOut: string;
    function GerarLote(const AInputDir, AOutputDir: string;
      const AOptions: TDanfeOptions): TArray<TDanfeResult>;
  end;

  TMemConsole = class(TInterfacedObject, ICliConsole)
  public
    Saida, Erros: string;
    procedure Out(const AText: string);
    procedure Err(const AText: string);
  end;

implementation

uses
  SysUtils;

function TFakeGenerator.Gerar(const AXmlFile: string; const ANota: TNotaInfo;
  const AOutputFile: string; const AOptions: TDanfeOptions): TDanfeResult;
var
  S: TStringList;
begin
  Inc(Chamadas);
  UltimaNota := ANota;
  UltimasOpcoes := AOptions;
  if LevantarExcecao then
    raise Exception.Create('falha simulada');
  S := TStringList.Create;
  try
    S.Text := '%PDF-fake ' + ANota.Chave;
    S.SaveToFile(AOutputFile);
  finally
    S.Free;
  end;
  Result := TDanfeResult.Ok(AXmlFile, AOutputFile);
end;

function TFakeService.GerarPdf(const AXmlFile, AOutputFile: string;
  const AOptions: TDanfeOptions): TDanfeResult;
begin
  UltimoXml := AXmlFile;
  UltimoOut := AOutputFile;
  UltimasOpcoes := AOptions;
  Result := Resultado;
end;

function TFakeBatch.GerarLote(const AInputDir, AOutputDir: string;
  const AOptions: TDanfeOptions): TArray<TDanfeResult>;
begin
  UltimoIn := AInputDir;
  UltimoOut := AOutputDir;
  Result := Resultados;
end;

procedure TMemConsole.Out(const AText: string);
begin
  Saida := Saida + AText + sLineBreak;
end;

procedure TMemConsole.Err(const AText: string);
begin
  Erros := Erros + AText + sLineBreak;
end;

end.
