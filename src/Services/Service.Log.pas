unit Service.Log;

{ Log em arquivo com rotacao diaria (um arquivo por dia). }

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

uses
  Domain.Interfaces;

type
  TFileLog = class(TInterfacedObject, ILogService)
  private
    FDir: string;
    procedure Escrever(const ANivel, AMessage: string);
  public
    constructor Create(const ADir: string);
    function ArquivoAtual: string;
    procedure Info(const AMessage: string);
    procedure Error(const AMessage: string);
  end;

  TNullLog = class(TInterfacedObject, ILogService)
  public
    procedure Info(const AMessage: string);
    procedure Error(const AMessage: string);
  end;

implementation

uses
  SysUtils;

constructor TFileLog.Create(const ADir: string);
begin
  inherited Create;
  FDir := IncludeTrailingPathDelimiter(ADir);
end;

function TFileLog.ArquivoAtual: string;
begin
  Result := FDir + 'danfeprint-' + FormatDateTime('yyyy-mm-dd', Now) + '.log';
end;

procedure TFileLog.Escrever(const ANivel, AMessage: string);
var
  F: TextFile;
  Arquivo: string;
begin
  // Falha de log nunca deve derrubar o processamento.
  try
    ForceDirectories(FDir);
    Arquivo := ArquivoAtual;
    AssignFile(F, Arquivo);
    if FileExists(Arquivo) then
      Append(F)
    else
      Rewrite(F);
    try
      WriteLn(F, FormatDateTime('hh:nn:ss.zzz', Now), ' [', ANivel, '] ', AMessage);
    finally
      CloseFile(F);
    end;
  except
    // ignora
  end;
end;

procedure TFileLog.Info(const AMessage: string);
begin
  Escrever('INFO', AMessage);
end;

procedure TFileLog.Error(const AMessage: string);
begin
  Escrever('ERRO', AMessage);
end;

procedure TNullLog.Info(const AMessage: string);
begin
end;

procedure TNullLog.Error(const AMessage: string);
begin
end;

end.
