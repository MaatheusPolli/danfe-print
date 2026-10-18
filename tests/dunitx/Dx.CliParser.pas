unit Dx.CliParser;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TCliParserTests = class
  public
    [Test] procedure SemArgumentosMostraAjuda;
    [Test] procedure HelpTemPrioridade;
    [Test] procedure ArquivoComTodasOpcoes;
    [Test] procedure LoteComPastas;
    [Test] procedure ModoInvalido;
    [Test] procedure ArgumentoDesconhecido;
    [Test] procedure ArgumentoSemValor;
    [Test] procedure ArgumentoDuplicado;
    [Test] procedure InEInDirJuntos;
    [Test] procedure SemEntrada;
    [Test] procedure OutSemIn;
    [Test] procedure OutDirSemInDir;
  end;

  [TestFixture]
  TCliRunnerTests = class
  public
    [Test] procedure ExitCodeZeroEmSucesso;
    [Test] procedure ExitCodeUmEmErroDeProcessamento;
    [Test] procedure ExitCodeDoisEmErroDeUso;
    [Test] procedure QuietSuprimeSaida;
    [Test] procedure LoteComFalhaRetornaUm;
    [Test] procedure LoteVazioRetornaUm;
    [Test] procedure AjudaRetornaZero;
  end;

implementation

uses
  System.SysUtils, Domain.Danfe, Cli.Parser, Cli.Runner, Tests.Mocks;

{ TCliParserTests }

procedure TCliParserTests.SemArgumentosMostraAjuda;
var
  R: TCliParseResult;
begin
  R := TCliParser.Parse([]);
  Assert.IsTrue(R.Success);
  Assert.IsTrue(R.Options.Acao = caAjuda);
end;

procedure TCliParserTests.HelpTemPrioridade;
begin
  Assert.IsFalse(TCliParser.Parse(['--xyz', '--help']).Success); // erro vem antes
  Assert.IsTrue(TCliParser.Parse(['--in', 'a.xml', '-h']).Options.Acao = caAjuda);
end;

procedure TCliParserTests.ArquivoComTodasOpcoes;
var
  R: TCliParseResult;
begin
  R := TCliParser.Parse(['--in', 'nota.xml', '--out', 'nota.pdf', '--modo', 'PAISAGEM',
    '--logo', 'logo.png', '--quiet']);
  Assert.IsTrue(R.Success, R.ErrorMessage);
  Assert.IsTrue(R.Options.Acao = caArquivo);
  Assert.AreEqual('nota.xml', R.Options.InFile);
  Assert.AreEqual('nota.pdf', R.Options.OutFile);
  Assert.AreEqual('logo.png', R.Options.Danfe.LogoFile);
  Assert.IsTrue(R.Options.Danfe.Orientacao = doPaisagem);
  Assert.IsTrue(R.Options.Quiet);
end;

procedure TCliParserTests.LoteComPastas;
var
  R: TCliParseResult;
begin
  R := TCliParser.Parse(['--in-dir', 'c:\xmls', '--out-dir', 'c:\pdfs']);
  Assert.IsTrue(R.Success, R.ErrorMessage);
  Assert.IsTrue(R.Options.Acao = caLote);
  Assert.AreEqual('c:\xmls', R.Options.InDir);
  Assert.AreEqual('c:\pdfs', R.Options.OutDir);
  Assert.IsTrue(R.Options.Danfe.Orientacao = doRetrato);
end;

procedure TCliParserTests.ModoInvalido;
begin
  Assert.IsFalse(TCliParser.Parse(['--in', 'a.xml', '--modo', 'diagonal']).Success);
end;

procedure TCliParserTests.ArgumentoDesconhecido;
var
  R: TCliParseResult;
begin
  R := TCliParser.Parse(['--in', 'a.xml', '--cor', 'azul']);
  Assert.IsFalse(R.Success);
  Assert.IsTrue(Pos('--cor', R.ErrorMessage) > 0);
end;

procedure TCliParserTests.ArgumentoSemValor;
begin
  Assert.IsFalse(TCliParser.Parse(['--in']).Success);
  Assert.IsFalse(TCliParser.Parse(['--in', '--quiet']).Success);
end;

procedure TCliParserTests.ArgumentoDuplicado;
begin
  Assert.IsFalse(TCliParser.Parse(['--in', 'a.xml', '--in', 'b.xml']).Success);
end;

procedure TCliParserTests.InEInDirJuntos;
begin
  Assert.IsFalse(TCliParser.Parse(['--in', 'a.xml', '--in-dir', 'x']).Success);
end;

procedure TCliParserTests.SemEntrada;
begin
  Assert.IsFalse(TCliParser.Parse(['--quiet']).Success);
end;

procedure TCliParserTests.OutSemIn;
begin
  Assert.IsFalse(TCliParser.Parse(['--in-dir', 'x', '--out', 'a.pdf']).Success);
end;

procedure TCliParserTests.OutDirSemInDir;
begin
  Assert.IsFalse(TCliParser.Parse(['--in', 'a.xml', '--out-dir', 'x']).Success);
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
    Assert.AreEqual(EXIT_OK, R.Run(['--in', 'a.xml', '--modo', 'paisagem']));
    Assert.AreEqual('a.xml', S.UltimoXml);
    Assert.IsTrue(S.UltimasOpcoes.Orientacao = doPaisagem);
    Assert.IsTrue(Pos('a.pdf', C.Saida) > 0);
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
    Assert.AreEqual(EXIT_ERRO_PROCESSAMENTO, R.Run(['--in', 'a.xml']));
    Assert.IsTrue(Pos('XML ruim', C.Erros) > 0);
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
    Assert.AreEqual(EXIT_ERRO_USO, R.Run(['--nada']));
    Assert.AreEqual('', S.UltimoXml);
    Assert.IsTrue(C.Erros <> '');
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
    Assert.AreEqual(EXIT_OK, R.Run(['--in', 'a.xml', '--quiet']));
    Assert.AreEqual('', C.Saida);
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
    Assert.AreEqual(EXIT_ERRO_PROCESSAMENTO, R.Run(['--in-dir', 'x', '--out-dir', 'y']));
    Assert.AreEqual('x', B.UltimoIn);
    Assert.AreEqual('y', B.UltimoOut);
    Assert.IsTrue(Pos('b.xml: quebrado', C.Erros) > 0);
    Assert.IsTrue(Pos('1 sucesso(s), 1 erro(s)', C.Saida) > 0);
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
    Assert.AreEqual(EXIT_ERRO_PROCESSAMENTO, R.Run(['--in-dir', 'x']));
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
    Assert.AreEqual(EXIT_OK, R.Run(['--help']));
    Assert.IsTrue(Pos('--in-dir', C.Saida) > 0);
  finally
    R.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TCliParserTests);
  TDUnitX.RegisterTestFixture(TCliRunnerTests);

end.
