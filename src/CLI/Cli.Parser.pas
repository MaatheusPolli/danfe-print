unit Cli.Parser;

{ Interpreta os argumentos de linha de comando (RF07).
  Uso:
    DanfePrint --in nota.xml [--out nota.pdf] [opcoes]
    DanfePrint --in-dir pasta [--out-dir saida] [opcoes]
  Opcoes: --modo retrato|paisagem, --logo arquivo, --quiet, --help }

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

uses
  Domain.Danfe;

const
  EXIT_OK = 0;
  EXIT_ERRO_PROCESSAMENTO = 1;
  EXIT_ERRO_USO = 2;

type
  TCliAcao = (caAjuda, caArquivo, caLote);

  TCliOptions = record
    Acao: TCliAcao;
    InFile: string;
    OutFile: string;
    InDir: string;
    OutDir: string;
    Quiet: Boolean;
    Danfe: TDanfeOptions;
  end;

  TCliParseResult = record
    Success: Boolean;
    Options: TCliOptions;
    ErrorMessage: string;
  end;

  TCliParser = class
  public
    class function Parse(const AArgs: array of string): TCliParseResult; static;
    class function TextoAjuda: string; static;
  end;

{ Le ParamStr(1..ParamCount) para um array. }
function ArgsDoProcesso: TArray<string>;

implementation

uses
  SysUtils;

resourcestring
  SArgDesconhecido = 'Argumento desconhecido: %s';
  SArgSemValor = 'Argumento %s exige um valor';
  SModoInvalido = 'Modo inv'#$E1'lido: %s (use retrato ou paisagem)';
  SArgDuplicado = 'Argumento informado mais de uma vez: %s';
  SEntradaObrigatoria = 'Informe --in <arquivo.xml> ou --in-dir <pasta>';
  SEntradasExclusivas = '--in e --in-dir n'#$E3'o podem ser usados juntos';
  SOutSemIn = '--out s'#$F3' pode ser usado com --in';
  SOutDirSemInDir = '--out-dir s'#$F3' pode ser usado com --in-dir';

  STextoAjuda =
    'DanfePrint - gera DANFE em PDF a partir do XML da NF-e/NFC-e' + sLineBreak +
    sLineBreak +
    'Uso:' + sLineBreak +
    '  DanfePrint --in nota.xml [--out nota.pdf] [op'#$E7#$F5'es]' + sLineBreak +
    '  DanfePrint --in-dir pasta [--out-dir saida] [op'#$E7#$F5'es]' + sLineBreak +
    sLineBreak +
    'Op'#$E7#$F5'es:' + sLineBreak +
    '  --modo retrato|paisagem   orienta'#$E7#$E3'o do DANFE (padr'#$E3'o: retrato)' + sLineBreak +
    '  --logo arquivo            logotipo a inserir no DANFE' + sLineBreak +
    '  --quiet                   n'#$E3'o escreve nada na sa'#$ED'da padr'#$E3'o' + sLineBreak +
    '  --help, -h                mostra esta ajuda' + sLineBreak +
    sLineBreak +
    'C'#$F3'digos de sa'#$ED'da: 0 sucesso, 1 erro de processamento, 2 erro de uso.';

function ArgsDoProcesso: TArray<string>;
var
  I: Integer;
begin
  Result := nil;
  SetLength(Result, ParamCount);
  for I := 1 to ParamCount do
    Result[I - 1] := ParamStr(I);
end;

class function TCliParser.TextoAjuda: string;
begin
  Result := STextoAjuda;
end;

class function TCliParser.Parse(const AArgs: array of string): TCliParseResult;
var
  I: Integer;
  Nome, Valor, Vistos: string;
  Modo: TDanfeOrientacao;

  function Falhar(const AMsg: string): TCliParseResult;
  begin
    Result := Default(TCliParseResult);
    Result.Success := False;
    Result.ErrorMessage := AMsg;
  end;

  function LerValor: Boolean;
  begin
    Result := (I < High(AArgs)) and (Copy(AArgs[I + 1], 1, 2) <> '--');
    if Result then
    begin
      Inc(I);
      Valor := AArgs[I];
    end;
  end;

begin
  Result := Default(TCliParseResult);
  Result.Success := True;
  Result.Options.Danfe := TDanfeOptions.Default;

  if Length(AArgs) = 0 then
  begin
    Result.Options.Acao := caAjuda;
    Exit;
  end;

  Vistos := '|';
  I := Low(AArgs);
  while I <= High(AArgs) do
  begin
    Nome := LowerCase(AArgs[I]);

    if (Nome = '--help') or (Nome = '-h') or (Nome = '/?') then
    begin
      Result.Options.Acao := caAjuda;
      Exit;
    end;

    if Pos('|' + Nome + '|', Vistos) > 0 then
      Exit(Falhar(Format(SArgDuplicado, [AArgs[I]])));
    Vistos := Vistos + Nome + '|';

    if Nome = '--quiet' then
      Result.Options.Quiet := True
    else if (Nome = '--in') or (Nome = '--out') or (Nome = '--in-dir') or
      (Nome = '--out-dir') or (Nome = '--logo') or (Nome = '--modo') then
    begin
      if not LerValor then
        Exit(Falhar(Format(SArgSemValor, [Nome])));
      if Nome = '--in' then
        Result.Options.InFile := Valor
      else if Nome = '--out' then
        Result.Options.OutFile := Valor
      else if Nome = '--in-dir' then
        Result.Options.InDir := Valor
      else if Nome = '--out-dir' then
        Result.Options.OutDir := Valor
      else if Nome = '--logo' then
        Result.Options.Danfe.LogoFile := Valor
      else
      begin
        if not TryStrToOrientacao(Valor, Modo) then
          Exit(Falhar(Format(SModoInvalido, [Valor])));
        Result.Options.Danfe.Orientacao := Modo;
      end;
    end
    else
      Exit(Falhar(Format(SArgDesconhecido, [AArgs[I]])));
    Inc(I);
  end;

  if (Result.Options.InFile <> '') and (Result.Options.InDir <> '') then
    Exit(Falhar(SEntradasExclusivas));
  if (Result.Options.InFile = '') and (Result.Options.InDir = '') then
    Exit(Falhar(SEntradaObrigatoria));
  if (Result.Options.OutFile <> '') and (Result.Options.InFile = '') then
    Exit(Falhar(SOutSemIn));
  if (Result.Options.OutDir <> '') and (Result.Options.InDir = '') then
    Exit(Falhar(SOutDirSemInDir));

  if Result.Options.InDir <> '' then
    Result.Options.Acao := caLote
  else
    Result.Options.Acao := caArquivo;
end;

end.
