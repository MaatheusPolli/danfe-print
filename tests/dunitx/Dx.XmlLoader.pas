unit Dx.XmlLoader;

interface

uses
  DUnitX.TestFramework, Domain.Danfe, Domain.Interfaces;

type
  [TestFixture]
  TXmlLoaderTests = class
  private
    FLoader: IXmlLoader;
    function Carregar(const AFixture: string): TXmlLoadResult;
    procedure CheckFalha(const AFixture, ATrecho: string);
  public
    [Setup] procedure Setup;
    [Test] procedure NfeProcAutorizada;
    [Test] procedure NfeSemProtocoloNaoAutorizada;
    [Test] procedure NfceModelo65;
    [Test] procedure ArquivoComBom;
    [Test] procedure ArquivoInexistente;
    [Test] procedure XmlMalFormado;
    [Test] procedure RaizInvalida;
    [Test] procedure SemInfNFe;
    [Test] procedure ModeloDesconhecido;
    [Test] procedure ModeloDivergente;
    [Test] procedure ChaveComDVErrado;
    [Test] procedure CalculoDV;
  end;

implementation

uses
  System.SysUtils, Service.XmlLoader, Tests.Helpers;

procedure TXmlLoaderTests.Setup;
begin
  FLoader := TXmlLoader.Create;
end;

function TXmlLoaderTests.Carregar(const AFixture: string): TXmlLoadResult;
begin
  Result := FLoader.Carregar(FixturePath(AFixture));
end;

procedure TXmlLoaderTests.CheckFalha(const AFixture, ATrecho: string);
var
  R: TXmlLoadResult;
begin
  R := Carregar(AFixture);
  Assert.IsFalse(R.Success, AFixture + ' deveria falhar');
  Assert.IsTrue(Pos(ATrecho, R.ErrorMessage) > 0,
    'Mensagem "' + R.ErrorMessage + '" deveria conter "' + ATrecho + '"');
end;

procedure TXmlLoaderTests.NfeProcAutorizada;
var
  R: TXmlLoadResult;
begin
  R := Carregar('nfe_autorizada.xml');
  Assert.IsTrue(R.Success, R.ErrorMessage);
  Assert.IsTrue(R.Nota.Autorizada);
  Assert.IsTrue(R.Nota.Modelo = mdNFe);
  Assert.AreEqual('35260911222333000181550010000000011123456780', R.Nota.Chave);
  Assert.AreEqual('1', R.Nota.Numero);
  Assert.AreEqual('11222333000181', R.Nota.CnpjEmitente);
end;

procedure TXmlLoaderTests.NfeSemProtocoloNaoAutorizada;
var
  R: TXmlLoadResult;
begin
  R := Carregar('nfe_sem_protocolo.xml');
  Assert.IsTrue(R.Success, R.ErrorMessage);
  Assert.IsFalse(R.Nota.Autorizada);
end;

procedure TXmlLoaderTests.NfceModelo65;
var
  R: TXmlLoadResult;
begin
  R := Carregar('nfce_autorizada.xml');
  Assert.IsTrue(R.Success, R.ErrorMessage);
  Assert.IsTrue(R.Nota.Modelo = mdNFCe);
end;

procedure TXmlLoaderTests.ArquivoComBom;
var
  R: TXmlLoadResult;
begin
  R := Carregar('nfe_com_bom.xml');
  Assert.IsTrue(R.Success, R.ErrorMessage);
end;

procedure TXmlLoaderTests.ArquivoInexistente;
begin
  CheckFalha('nao_existe.xml', 'encontrado');
end;

procedure TXmlLoaderTests.XmlMalFormado;
begin
  CheckFalha('invalido_mal_formado.xml', 'mal formado');
end;

procedure TXmlLoaderTests.RaizInvalida;
begin
  CheckFalha('invalido_raiz.xml', 'cteProc');
end;

procedure TXmlLoaderTests.SemInfNFe;
begin
  CheckFalha('invalido_sem_infnfe.xml', 'infNFe');
end;

procedure TXmlLoaderTests.ModeloDesconhecido;
begin
  CheckFalha('invalido_modelo.xml', 'suportado: 57');
end;

procedure TXmlLoaderTests.ModeloDivergente;
begin
  CheckFalha('invalido_modelo_divergente.xml', 'diverge');
end;

procedure TXmlLoaderTests.ChaveComDVErrado;
begin
  CheckFalha('invalido_chave.xml', 'Chave de acesso inv');
end;

procedure TXmlLoaderTests.CalculoDV;
begin
  Assert.AreEqual(0, CalcularDVChave('3526091122233300018155001000000001112345678'));
  Assert.IsFalse(ChaveValida('123'));
  Assert.IsFalse(ChaveValida('3526091122233300018155001000000001112345678X'));
end;

initialization
  TDUnitX.RegisterTestFixture(TXmlLoaderTests);

end.
