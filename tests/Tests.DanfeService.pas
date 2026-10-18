unit Tests.DanfeService;

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

uses
  fpcunit, testregistry, Domain.Interfaces, Tests.Mocks;

type
  TDanfeServiceTests = class(TTestCase)
  private
    FGen: TFakeGenerator;
    FGenRef: IDanfeGenerator;
    FService: IDanfeService;
    FOut: string;
  protected
    procedure SetUp; override;
  published
    procedure GeraPdfDeXmlValido;
    procedure SaidaPadraoAoLadoDoXml;
    procedure XmlInvalidoNaoChamaGerador;
    procedure ExcecaoDoGeradorViraResultado;
    procedure OpcoesRepassadas;
  end;

implementation

uses
  SysUtils, Domain.Danfe, Service.Danfe, Service.XmlLoader, Service.Log, Tests.Helpers;

procedure TDanfeServiceTests.SetUp;
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
  AssertTrue(R.ErrorMessage, R.Success);
  AssertTrue(FileExists(FOut + 'sub\a.pdf'));
  AssertTrue(FGen.UltimaNota.Autorizada);
end;

procedure TDanfeServiceTests.SaidaPadraoAoLadoDoXml;
begin
  AssertEquals('c:\x\nota.pdf', OutputPadrao('c:\x\nota.xml', ''));
  AssertEquals('d:\y\nota.pdf', OutputPadrao('c:\x\nota.xml', 'd:\y'));
end;

procedure TDanfeServiceTests.XmlInvalidoNaoChamaGerador;
var
  R: TDanfeResult;
begin
  R := FService.GerarPdf(FixturePath('invalido_chave.xml'), FOut + 'b.pdf',
    TDanfeOptions.Default);
  AssertFalse(R.Success);
  AssertEquals(0, FGen.Chamadas);
end;

procedure TDanfeServiceTests.ExcecaoDoGeradorViraResultado;
var
  R: TDanfeResult;
begin
  FGen.LevantarExcecao := True;
  R := FService.GerarPdf(FixturePath('nfe_autorizada.xml'), FOut + 'c.pdf',
    TDanfeOptions.Default);
  AssertFalse(R.Success);
  AssertTrue(Pos('falha simulada', R.ErrorMessage) > 0);
end;

procedure TDanfeServiceTests.OpcoesRepassadas;
var
  O: TDanfeOptions;
begin
  O := TDanfeOptions.Default;
  O.Orientacao := doPaisagem;
  O.LogoFile := 'logo.png';
  FService.GerarPdf(FixturePath('nfce_autorizada.xml'), FOut + 'd.pdf', O);
  AssertTrue(FGen.UltimasOpcoes.Orientacao = doPaisagem);
  AssertEquals('logo.png', FGen.UltimasOpcoes.LogoFile);
  AssertTrue(FGen.UltimaNota.Modelo = mdNFCe);
end;

initialization
  RegisterTest(TDanfeServiceTests);

end.
