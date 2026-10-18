unit App.Config;

{ Configuracao persistida em INI (RF08): ultima pasta, logo, orientacao padrao. }

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

uses
  Domain.Danfe;

type
  TAppConfig = class
  private
    FArquivo: string;
  public
    UltimaPasta: string;
    UltimaPastaSaida: string;
    LogoFile: string;
    Orientacao: TDanfeOrientacao;
    constructor Create(const AArquivo: string);
    procedure Carregar;
    procedure Salvar;
    function DanfeOptions: TDanfeOptions;
    property Arquivo: string read FArquivo;
    { DanfePrint.ini ao lado do executavel. }
    class function ArquivoPadrao: string; static;
  end;

implementation

uses
  SysUtils, IniFiles;

const
  SEC_GERAL = 'Geral';
  SEC_DANFE = 'Danfe';

constructor TAppConfig.Create(const AArquivo: string);
begin
  inherited Create;
  FArquivo := AArquivo;
  Orientacao := doRetrato;
end;

class function TAppConfig.ArquivoPadrao: string;
begin
  Result := ChangeFileExt(ParamStr(0), '.ini');
end;

procedure TAppConfig.Carregar;
var
  Ini: TIniFile;
begin
  if not FileExists(FArquivo) then
    Exit;
  Ini := TIniFile.Create(FArquivo);
  try
    UltimaPasta := Ini.ReadString(SEC_GERAL, 'UltimaPasta', '');
    UltimaPastaSaida := Ini.ReadString(SEC_GERAL, 'UltimaPastaSaida', '');
    LogoFile := Ini.ReadString(SEC_DANFE, 'Logo', '');
    if not TryStrToOrientacao(Ini.ReadString(SEC_DANFE, 'Orientacao', ''), Orientacao) then
      Orientacao := doRetrato;
  finally
    Ini.Free;
  end;
end;

procedure TAppConfig.Salvar;
var
  Ini: TIniFile;
begin
  ForceDirectories(ExtractFileDir(FArquivo));
  Ini := TIniFile.Create(FArquivo);
  try
    Ini.WriteString(SEC_GERAL, 'UltimaPasta', UltimaPasta);
    Ini.WriteString(SEC_GERAL, 'UltimaPastaSaida', UltimaPastaSaida);
    Ini.WriteString(SEC_DANFE, 'Logo', LogoFile);
    Ini.WriteString(SEC_DANFE, 'Orientacao', OrientacaoToStr(Orientacao));
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

function TAppConfig.DanfeOptions: TDanfeOptions;
begin
  Result := TDanfeOptions.Default;
  Result.Orientacao := Orientacao;
  Result.LogoFile := LogoFile;
end;

end.
