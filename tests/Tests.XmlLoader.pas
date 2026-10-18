unit Tests.XmlLoader;

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

uses
  fpcunit, testregistry, Domain.Danfe, Domain.Interfaces;

type
  TXmlLoaderTests = class(TTestCase)
  private
    FLoader: IXmlLoader;
    function Carregar(const AFixture: string): TXmlLoadResult;
    procedure CheckFalha(const AFixture, ATrecho: string);
  protected
    procedure SetUp; override;
  published
    procedure NfeProcAutorizada;
    procedure NfeSemProtocoloNaoAutorizada;
    procedure NfceModelo65;
    procedure ArquivoComBom;
    procedure ArquivoInexistente;
    procedure XmlMalFormado;
    procedure RaizInvalida;
    procedure SemInfNFe;
    procedure ModeloDesconhecido;
    procedure ModeloDivergente;
    procedure ChaveComDVErrado;
    procedure CalculoDV;
  end;

implementation

uses
  SysUtils, Service.XmlLoader, Tests.Helpers;

procedure TXmlLoaderTests.SetUp;
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
  AssertFalse(AFixture + ' deveria falhar', R.Success);
  AssertTrue('Mensagem "' + R.ErrorMessage + '" deveria conter "' + ATrecho + '"',
    Pos(ATrecho, R.ErrorMessage) > 0);
end;

procedure TXmlLoaderTests.NfeProcAutorizada;
var
  R: TXmlLoadResult;
begin
  R := Carregar('nfe_autorizada.xml');
  AssertTrue(R.ErrorMessage, R.Success);
  AssertTrue(R.Nota.Autorizada);
  AssertTrue(R.Nota.Modelo = mdNFe);
  AssertEquals('35260911222333000181550010000000011123456780', R.Nota.Chave);
  AssertEquals('1', R.Nota.Numero);
  AssertEquals('11222333000181', R.Nota.CnpjEmitente);
end;

procedure TXmlLoaderTests.NfeSemProtocoloNaoAutorizada;
var
  R: TXmlLoadResult;
begin
  R := Carregar('nfe_sem_protocolo.xml');
  AssertTrue(R.ErrorMessage, R.Success);
  AssertFalse(R.Nota.Autorizada);
end;

procedure TXmlLoaderTests.NfceModelo65;
var
  R: TXmlLoadResult;
begin
  R := Carregar('nfce_autorizada.xml');
  AssertTrue(R.ErrorMessage, R.Success);
  AssertTrue(R.Nota.Modelo = mdNFCe);
end;

procedure TXmlLoaderTests.ArquivoComBom;
var
  R: TXmlLoadResult;
begin
  R := Carregar('nfe_com_bom.xml');
  AssertTrue(R.ErrorMessage, R.Success);
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
  AssertEquals(0, CalcularDVChave('3526091122233300018155001000000001112345678'));
  AssertFalse(ChaveValida('123'));
  AssertFalse(ChaveValida('3526091122233300018155001000000001112345678X'));
end;

initialization
  RegisterTest(TXmlLoaderTests);

end.
