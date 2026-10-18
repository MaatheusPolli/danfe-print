unit Dx.DanfeService;

interface

uses
  DUnitX.TestFramework, Domain.Interfaces, Tests.Mocks;

type
  [TestFixture]
  TDanfeServiceTests = class
  private
    FGen: TFakeGenerator;
    FGenRef: IDanfeGenerator;
    FService: IDanfeService;
    FOut: string;
  public
    [Setup] procedure Setup;
    [Test] procedure GeraPdfDeXmlValido;
    [Test] procedure SaidaPadraoAoLadoDoXml;
    [Test] procedure XmlInvalidoNaoChamaGerador;
    [Test] procedure ExcecaoDoGeradorViraResultado;
    [Test] procedure OpcoesRepassadas;
  end;

implementation

uses
  System.SysUtils, Domain.Danfe, Service.Danfe, Service.XmlLoader, Service.Log, Tests.Helpers;

procedure TDanfeServiceTests.Setup;
begin
  FGen := TFakeGenerator.Create;
  FGenRef := FGen;
  FService := TDanfeService.Create(TXmlLoader.Create, FGenRef, TNullLog.Create);
  FOut := TempDir('service');
end;

procedure TDanfeServiceTests.GeraPdfDeXmlValido;
var
  R: TDanfeResult;
begin
  R := FService.GerarPdf(FixturePath('nfe_autorizada.xml'), FOut + 'sub\a.pdf',
    TDanfeOptions.Default);
  Assert.IsTrue(R.Success, R.ErrorMessage);
  Assert.IsTrue(FileExists(FOut + 'sub\a.pdf'));
  Assert.IsTrue(FGen.UltimaNota.Autorizada);
end;

procedure TDanfeServiceTests.SaidaPadraoAoLadoDoXml;
begin
  Assert.AreEqual('c:\x\nota.pdf', OutputPadrao('c:\x\nota.xml', ''));
  Assert.AreEqual('d:\y\nota.pdf', OutputPadrao('c:\x\nota.xml', 'd:\y'));
end;

procedure TDanfeServiceTests.XmlInvalidoNaoChamaGerador;
var
  R: TDanfeResult;
begin
  R := FService.GerarPdf(FixturePath('invalido_chave.xml'), FOut + 'b.pdf',
    TDanfeOptions.Default);
  Assert.IsFalse(R.Success);
  Assert.AreEqual(0, FGen.Chamadas);
end;

procedure TDanfeServiceTests.ExcecaoDoGeradorViraResultado;
var
  R: TDanfeResult;
begin
  FGen.LevantarExcecao := True;
  R := FService.GerarPdf(FixturePath('nfe_autorizada.xml'), FOut + 'c.pdf',
    TDanfeOptions.Default);
  Assert.IsFalse(R.Success);
  Assert.IsTrue(Pos('falha simulada', R.ErrorMessage) > 0);
end;

procedure TDanfeServiceTests.OpcoesRepassadas;
var
  O: TDanfeOptions;
begin
  O := TDanfeOptions.Default;
  O.Orientacao := doPaisagem;
  O.LogoFile := 'logo.png';
  FService.GerarPdf(FixturePath('nfce_autorizada.xml'), FOut + 'd.pdf', O);
  Assert.IsTrue(FGen.UltimasOpcoes.Orientacao = doPaisagem);
  Assert.AreEqual('logo.png', FGen.UltimasOpcoes.LogoFile);
  Assert.IsTrue(FGen.UltimaNota.Modelo = mdNFCe);
end;

initialization
  TDUnitX.RegisterTestFixture(TDanfeServiceTests);

end.
