unit Dx.AcbrFacade;

{ Teste de integracao do gerador real de PDF (IDanfeGenerator via facade).
  Categoria "integration": gera PDF de verdade a partir das fixtures e confere
  a assinatura "%PDF" e um tamanho plausivel. Excluir com --exclude:integration. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  [Category('integration')]
  TAcbrFacadeTests = class
  private
    function GerarDe(const AFixture: string): string;
    function LerInicio(const AArquivo: string): string;
    function TamArquivo(const AArquivo: string): Int64;
  public
    [Test] procedure GeraPdfNFeAutorizada;
    [Test] procedure GeraPdfPaisagem;
    [Test] procedure GeraPdfNFCe;
    [Test] procedure NotaSemProtocoloGeraPdf;
  end;

implementation

uses
  System.SysUtils, System.Classes, Domain.Danfe, Domain.Interfaces,
  Service.XmlLoader, Infra.AcbrFacade, Tests.Helpers;

function TAcbrFacadeTests.LerInicio(const AArquivo: string): string;
var
  F: TFileStream;
  Buf: array[0..3] of AnsiChar;
  Lidos: Integer;
begin
  Result := '';
  F := TFileStream.Create(AArquivo, fmOpenRead or fmShareDenyNone);
  try
    Lidos := F.Read(Buf, SizeOf(Buf));
    SetString(Result, PAnsiChar(@Buf[0]), Lidos);
  finally
    F.Free;
  end;
end;

function TAcbrFacadeTests.TamArquivo(const AArquivo: string): Int64;
var
  F: TFileStream;
begin
  F := TFileStream.Create(AArquivo, fmOpenRead or fmShareDenyNone);
  try
    Result := F.Size;
  finally
    F.Free;
  end;
end;

function TAcbrFacadeTests.GerarDe(const AFixture: string): string;
var
  Loader: IXmlLoader;
  Gen: IDanfeGenerator;
  Carga: TXmlLoadResult;
  R: TDanfeResult;
begin
  Loader := TXmlLoader.Create;
  Carga := Loader.Carregar(FixturePath(AFixture));
  Assert.IsTrue(Carga.Success, 'fixture deveria carregar: ' + AFixture);

  Result := TempDir('pdf') + ChangeFileExt(AFixture, '.pdf');
  DeleteFile(Result);

  Gen := CriarGeradorDanfe;
  R := Gen.Gerar(FixturePath(AFixture), Carga.Nota, Result, TDanfeOptions.Default);
  Assert.IsTrue(R.Success, 'geracao falhou: ' + R.ErrorMessage);
end;

procedure TAcbrFacadeTests.GeraPdfNFeAutorizada;
var
  Saida: string;
begin
  Saida := GerarDe('nfe_autorizada.xml');
  Assert.IsTrue(FileExists(Saida), 'PDF deveria existir');
  Assert.AreEqual('%PDF', LerInicio(Saida));
  Assert.IsTrue(TamArquivo(Saida) > 500, 'tamanho plausivel (>500 bytes)');
end;

procedure TAcbrFacadeTests.GeraPdfPaisagem;
var
  Loader: IXmlLoader;
  Gen: IDanfeGenerator;
  Carga: TXmlLoadResult;
  Opt: TDanfeOptions;
  R: TDanfeResult;
  Saida: string;
begin
  Loader := TXmlLoader.Create;
  Carga := Loader.Carregar(FixturePath('nfe_autorizada.xml'));
  Assert.IsTrue(Carga.Success);
  Opt := TDanfeOptions.Default;
  Opt.Orientacao := doPaisagem;
  Saida := TempDir('pdf') + 'paisagem.pdf';
  DeleteFile(Saida);
  Gen := CriarGeradorDanfe;
  R := Gen.Gerar(FixturePath('nfe_autorizada.xml'), Carga.Nota, Saida, Opt);
  Assert.IsTrue(R.Success, 'geracao paisagem');
  Assert.IsTrue(FileExists(Saida));
  Assert.AreEqual('%PDF', LerInicio(Saida));
end;

procedure TAcbrFacadeTests.GeraPdfNFCe;
var
  Saida: string;
begin
  Saida := GerarDe('nfce_autorizada.xml');
  Assert.IsTrue(FileExists(Saida));
  Assert.AreEqual('%PDF', LerInicio(Saida));
end;

procedure TAcbrFacadeTests.NotaSemProtocoloGeraPdf;
var
  Saida: string;
begin
  { nota sem protocolo deve gerar PDF (marcado SEM VALOR FISCAL internamente). }
  Saida := GerarDe('nfe_sem_protocolo.xml');
  Assert.IsTrue(FileExists(Saida));
  Assert.AreEqual('%PDF', LerInicio(Saida));
  Assert.IsTrue(TamArquivo(Saida) > 500);
end;

initialization
  TDUnitX.RegisterTestFixture(TAcbrFacadeTests);

end.
