unit Tests.CliParser;

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

uses
  fpcunit, testregistry;

type
  TCliParserTests = class(TTestCase)
  published
    procedure SemArgumentosMostraAjuda;
    procedure HelpTemPrioridade;
    procedure ArquivoComTodasOpcoes;
    procedure LoteComPastas;
    procedure ModoInvalido;
    procedure ArgumentoDesconhecido;
    procedure ArgumentoSemValor;
    procedure ArgumentoDuplicado;
    procedure InEInDirJuntos;
    procedure SemEntrada;
    procedure OutSemIn;
    procedure OutDirSemInDir;
  end;

  TCliRunnerTests = class(TTestCase)
  published
    procedure ExitCodeZeroEmSucesso;
    procedure ExitCodeUmEmErroDeProcessamento;
    procedure ExitCodeDoisEmErroDeUso;
    procedure QuietSuprimeSaida;
    procedure LoteComFalhaRetornaUm;
    procedure LoteVazioRetornaUm;
    procedure AjudaRetornaZero;
  end;

implementation

uses
  SysUtils, Domain.Danfe, Cli.Parser, Cli.Runner, Tests.Mocks;

{ TCliParserTests }

procedure TCliParserTests.SemArgumentosMostraAjuda;
var
  R: TCliParseResult;
begin
  R := TCliParser.Parse([]);
  AssertTrue(R.Success);
  AssertTrue(R.Options.Acao = caAjuda);
end;

procedure TCliParserTests.HelpTemPrioridade;
begin
  AssertTrue(TCliParser.Parse(['--xyz', '--help']).Success = False); // erro vem antes
  AssertTrue(TCliParser.Parse(['--in', 'a.xml', '-h']).Options.Acao = caAjuda);
end;

procedure TCliParserTests.ArquivoComTodasOpcoes;
var
  R: TCliParseResult;
begin
  R := TCliParser.Parse(['--in', 'nota.xml', '--out', 'nota.pdf', '--modo', 'PAISAGEM',
    '--logo', 'logo.png', '--quiet']);
  AssertTrue(R.ErrorMessage, R.Success);
  AssertTrue(R.Options.Acao = caArquivo);
  AssertEquals('nota.xml', R.Options.InFile);
  AssertEquals('nota.pdf', R.Options.OutFile);
  AssertEquals('logo.png', R.Options.Danfe.LogoFile);
  AssertTrue(R.Options.Danfe.Orientacao = doPaisagem);
  AssertTrue(R.Options.Quiet);
end;

procedure TCliParserTests.LoteComPastas;
var
  R: TCliParseResult;
begin
  R := TCliParser.Parse(['--in-dir', 'c:\xmls', '--out-dir', 'c:\pdfs']);
  AssertTrue(R.ErrorMessage, R.Success);
  AssertTrue(R.Options.Acao = caLote);
  AssertEquals('c:\xmls', R.Options.InDir);
  AssertEquals('c:\pdfs', R.Options.OutDir);
  AssertTrue(R.Options.Danfe.Orientacao = doRetrato);
end;

procedure TCliParserTests.ModoInvalido;
begin
  AssertFalse(TCliParser.Parse(['--in', 'a.xml', '--modo', 'diagonal']).Success);
end;

procedure TCliParserTests.ArgumentoDesconhecido;
var
  R: TCliParseResult;
begin
  R := TCliParser.Parse(['--in', 'a.xml', '--cor', 'azul']);
  AssertFalse(R.Success);
  AssertTrue(Pos('--cor', R.ErrorMessage) > 0);
end;

procedure TCliParserTests.ArgumentoSemValor;
begin
  AssertFalse(TCliParser.Parse(['--in']).Success);
  AssertFalse(TCliParser.Parse(['--in', '--quiet']).Success);
end;

procedure TCliParserTests.ArgumentoDuplicado;
begin
  AssertFalse(TCliParser.Parse(['--in', 'a.xml', '--in', 'b.xml']).Success);
end;

procedure TCliParserTests.InEInDirJuntos;
begin
  AssertFalse(TCliParser.Parse(['--in', 'a.xml', '--in-dir', 'x']).Success);
end;

procedure TCliParserTests.SemEntrada;
begin
  AssertFalse(TCliParser.Parse(['--quiet']).Success);
end;

procedure TCliParserTests.OutSemIn;
begin
  AssertFalse(TCliParser.Parse(['--in-dir', 'x', '--out', 'a.pdf']).Success);
end;

procedure TCliParserTests.OutDirSemInDir;
begin
  AssertFalse(TCliParser.Parse(['--in', 'a.xml', '--out-dir', 'x']).Success);
end;

{ TCliRunnerTests }

function NovoRunner(out AService: TFakeService; out ABatch: TFakeBatch;
  out AConsole: TMemConsole): TCliRunner;
begin
  AService := TFakeService.Create;
  ABatch := TFakeBatch.Create;
  AConsole := TMemConsole.Create;
  Result := TCliRunner.Create(AService, ABatch, AConsole);
end;

procedure TCliRunnerTests.ExitCodeZeroEmSucesso;
var
  S: TFakeService; B: TFakeBatch; C: TMemConsole; R: TCliRunner;
begin
  R := NovoRunner(S, B, C);
  try
    S.Resultado := TDanfeResult.Ok('a.xml', 'a.pdf');
    AssertEquals(EXIT_OK, R.Run(['--in', 'a.xml', '--modo', 'paisagem']));
    AssertEquals('a.xml', S.UltimoXml);
    AssertTrue(S.UltimasOpcoes.Orientacao = doPaisagem);
    AssertTrue(Pos('a.pdf', C.Saida) > 0);
  finally
    R.Free;
  end;
end;

procedure TCliRunnerTests.ExitCodeUmEmErroDeProcessamento;
var
  S: TFakeService; B: TFakeBatch; C: TMemConsole; R: TCliRunner;
begin
  R := NovoRunner(S, B, C);
  try
    S.Resultado := TDanfeResult.Fail('a.xml', 'XML ruim');
    AssertEquals(EXIT_ERRO_PROCESSAMENTO, R.Run(['--in', 'a.xml']));
    AssertTrue(Pos('XML ruim', C.Erros) > 0);
  finally
    R.Free;
  end;
end;

procedure TCliRunnerTests.ExitCodeDoisEmErroDeUso;
var
  S: TFakeService; B: TFakeBatch; C: TMemConsole; R: TCliRunner;
begin
  R := NovoRunner(S, B, C);
  try
    AssertEquals(EXIT_ERRO_USO, R.Run(['--nada']));
    AssertEquals('', S.UltimoXml);
    AssertTrue(C.Erros <> '');
  finally
    R.Free;
  end;
end;

procedure TCliRunnerTests.QuietSuprimeSaida;
var
  S: TFakeService; B: TFakeBatch; C: TMemConsole; R: TCliRunner;
begin
  R := NovoRunner(S, B, C);
  try
    S.Resultado := TDanfeResult.Ok('a.xml', 'a.pdf');
    AssertEquals(EXIT_OK, R.Run(['--in', 'a.xml', '--quiet']));
    AssertEquals('', C.Saida);
  finally
    R.Free;
  end;
end;

procedure TCliRunnerTests.LoteComFalhaRetornaUm;
var
  S: TFakeService; B: TFakeBatch; C: TMemConsole; R: TCliRunner;
begin
  R := NovoRunner(S, B, C);
  try
    B.Resultados := [TDanfeResult.Ok('a.xml', 'a.pdf'), TDanfeResult.Fail('b.xml', 'quebrado')];
    AssertEquals(EXIT_ERRO_PROCESSAMENTO, R.Run(['--in-dir', 'x', '--out-dir', 'y']));
    AssertEquals('x', B.UltimoIn);
    AssertEquals('y', B.UltimoOut);
    AssertTrue(Pos('b.xml: quebrado', C.Erros) > 0);
    AssertTrue(Pos('1 sucesso(s), 1 erro(s)', C.Saida) > 0);
  finally
    R.Free;
  end;
end;

procedure TCliRunnerTests.LoteVazioRetornaUm;
var
  S: TFakeService; B: TFakeBatch; C: TMemConsole; R: TCliRunner;
begin
  R := NovoRunner(S, B, C);
  try
    AssertEquals(EXIT_ERRO_PROCESSAMENTO, R.Run(['--in-dir', 'x']));
  finally
    R.Free;
  end;
end;

procedure TCliRunnerTests.AjudaRetornaZero;
var
  S: TFakeService; B: TFakeBatch; C: TMemConsole; R: TCliRunner;
begin
  R := NovoRunner(S, B, C);
  try
    AssertEquals(EXIT_OK, R.Run(['--help']));
    AssertTrue(Pos('--in-dir', C.Saida) > 0);
  finally
    R.Free;
  end;
end;

initialization
  RegisterTest(TCliParserTests);
  RegisterTest(TCliRunnerTests);

end.
