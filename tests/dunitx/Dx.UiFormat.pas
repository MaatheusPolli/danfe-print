unit Dx.UiFormat;

{ Testa as regras de apresentacao da GUI (UI.Format), sem precisar de VCL. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TUiFormatTests = class
  public
    [Test] procedure LinhaDeSucesso;
    [Test] procedure LinhaDeErroTemMensagem;
    [Test] procedure ResumoDoLote;
    [Test] procedure IndiceDeOrientacaoIdaEVolta;
    [Test] procedure IndiceInvalidoVoltaParaRetrato;
    [Test] procedure EntradasPreenchidas;
  end;

implementation

uses
  Domain.Danfe, UI.Format;

procedure TUiFormatTests.LinhaDeSucesso;
begin
  Assert.AreEqual('OK    nota.xml', LinhaResultadoLote(TDanfeResult.Ok('c:\x\nota.xml', 'c:\x\nota.pdf')));
end;

procedure TUiFormatTests.LinhaDeErroTemMensagem;
begin
  Assert.AreEqual('ERRO  ruim.xml: XML mal formado',
    LinhaResultadoLote(TDanfeResult.Fail('c:\x\ruim.xml', 'XML mal formado')));
end;

procedure TUiFormatTests.ResumoDoLote;
begin
  Assert.AreEqual('Lote conclu'#$ED'do: 3 sucesso(s), 1 erro(s)', ResumoLote(3, 1));
end;

procedure TUiFormatTests.IndiceDeOrientacaoIdaEVolta;
begin
  Assert.AreEqual(0, IndiceOrientacao(doRetrato));
  Assert.AreEqual(1, IndiceOrientacao(doPaisagem));
  Assert.IsTrue(OrientacaoDoIndice(0) = doRetrato);
  Assert.IsTrue(OrientacaoDoIndice(1) = doPaisagem);
end;

procedure TUiFormatTests.IndiceInvalidoVoltaParaRetrato;
begin
  Assert.IsTrue(OrientacaoDoIndice(-1) = doRetrato);
  Assert.IsTrue(OrientacaoDoIndice(7) = doRetrato);
end;

procedure TUiFormatTests.EntradasPreenchidas;
begin
  Assert.IsTrue(UI.Format.EntradasPreenchidas('c:\in', 'c:\out'));
  Assert.IsFalse(UI.Format.EntradasPreenchidas('', 'c:\out'));
  Assert.IsFalse(UI.Format.EntradasPreenchidas('c:\in', '   '));
end;

initialization
  TDUnitX.RegisterTestFixture(TUiFormatTests);

end.
