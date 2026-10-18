unit Dx.Config;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TConfigTests = class
  public
    [Test] procedure ArquivoInexistenteUsaPadroes;
    [Test] procedure SalvaECarrega;
    [Test] procedure OrientacaoInvalidaVoltaParaRetrato;
  end;

implementation

uses
  System.SysUtils, System.Classes, Domain.Danfe, App.Config, Tests.Helpers;

procedure TConfigTests.ArquivoInexistenteUsaPadroes;
var
  C: TAppConfig;
begin
  C := TAppConfig.Create(TempDir('config') + 'nao-existe.ini');
  try
    C.Carregar;
    Assert.AreEqual('', C.UltimaPasta);
    Assert.IsTrue(C.Orientacao = doRetrato);
  finally
    C.Free;
  end;
end;

procedure TConfigTests.SalvaECarrega;
var
  C: TAppConfig;
  Arq: string;
begin
  Arq := TempDir('config') + 'salva.ini';
  DeleteFile(Arq);
  C := TAppConfig.Create(Arq);
  try
    C.UltimaPasta := 'c:\notas';
    C.UltimaPastaSaida := 'c:\pdfs';
    C.LogoFile := 'c:\logo.png';
    C.Orientacao := doPaisagem;
    C.Salvar;
  finally
    C.Free;
  end;

  C := TAppConfig.Create(Arq);
  try
    C.Carregar;
    Assert.AreEqual('c:\notas', C.UltimaPasta);
    Assert.AreEqual('c:\pdfs', C.UltimaPastaSaida);
    Assert.AreEqual('c:\logo.png', C.DanfeOptions.LogoFile);
    Assert.IsTrue(C.DanfeOptions.Orientacao = doPaisagem);
  finally
    C.Free;
  end;
end;

procedure TConfigTests.OrientacaoInvalidaVoltaParaRetrato;
var
  C: TAppConfig;
  L: TStringList;
  Arq: string;
begin
  Arq := TempDir('config') + 'invalida.ini';
  L := TStringList.Create;
  try
    L.Add('[Danfe]');
    L.Add('Orientacao=diagonal');
    L.SaveToFile(Arq);
  finally
    L.Free;
  end;
  C := TAppConfig.Create(Arq);
  try
    C.Carregar;
    Assert.IsTrue(C.Orientacao = doRetrato);
  finally
    C.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TConfigTests);

end.
