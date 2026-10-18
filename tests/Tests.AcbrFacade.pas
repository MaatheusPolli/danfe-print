unit Tests.AcbrFacade;

{ Teste de integracao do gerador real de PDF (IDanfeGenerator via facade).

  No FPC usa o backend FPDF-Pascal e gera um PDF de verdade a partir de uma
  fixture; verifica existencia, assinatura "%PDF" e tamanho plausivel.
  Equivale ao teste [Category('integration')] previsto para o Delphi. }

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

uses
  fpcunit, testregistry;

type
  TAcbrFacadeTests = class(TTestCase)
  private
    function GerarDe(const AFixture: string; out AOut: string): Boolean;
    function LerInicio(const AArquivo: string): string;
    function TamArquivo(const AArquivo: string): Int64;
  published
    procedure GeraPdfNFeAutorizada;
    procedure GeraPdfPaisagem;
    procedure GeraPdfNFCe;
    procedure NotaSemProtocoloGeraPdf;
  end;

implementation

uses
  SysUtils, Classes,
  Domain.Danfe, Domain.Interfaces,
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

function TAcbrFacadeTests.GerarDe(const AFixture: string; out AOut: string): Boolean;
var
  Loader: IXmlLoader;
  Gen: IDanfeGenerator;
  Carga: TXmlLoadResult;
  Opt: TDanfeOptions;
  R: TDanfeResult;
begin
  Loader := TXmlLoader.Create;
  Carga := Loader.Carregar(FixturePath(AFixture));
  AssertTrue('fixture deveria carregar: ' + AFixture, Carga.Success);

  Opt := TDanfeOptions.Default;
  AOut := TempDir('pdf') + ChangeFileExt(AFixture, '.pdf');
  DeleteFile(AOut);

  Gen := CriarGeradorDanfe;
  R := Gen.Gerar(FixturePath(AFixture), Carga.Nota, AOut, Opt);
  if not R.Success then
    Fail('geracao falhou: ' + R.ErrorMessage);
  Result := R.Success;
end;

procedure TAcbrFacadeTests.GeraPdfNFeAutorizada;
var
  Saida: string;
begin
  GerarDe('nfe_autorizada.xml', Saida);
  AssertTrue('PDF deveria existir', FileExists(Saida));
  AssertEquals('assinatura PDF', '%PDF', LerInicio(Saida));
  AssertTrue('tamanho plausivel (>500 bytes)', TamArquivo(Saida) > 500);
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
  AssertTrue(Carga.Success);
  Opt := TDanfeOptions.Default;
  Opt.Orientacao := doPaisagem;
  Saida := TempDir('pdf') + 'paisagem.pdf';
  DeleteFile(Saida);
  Gen := CriarGeradorDanfe;
  R := Gen.Gerar(FixturePath('nfe_autorizada.xml'), Carga.Nota, Saida, Opt);
  AssertTrue('geracao paisagem', R.Success);
  AssertTrue(FileExists(Saida));
  AssertEquals('%PDF', LerInicio(Saida));
end;

procedure TAcbrFacadeTests.GeraPdfNFCe;
var
  Saida: string;
begin
  GerarDe('nfce_autorizada.xml', Saida);
  AssertTrue(FileExists(Saida));
  AssertEquals('%PDF', LerInicio(Saida));
end;

procedure TAcbrFacadeTests.NotaSemProtocoloGeraPdf;
var
  Saida: string;
begin
  { nota sem protocolo deve gerar PDF (marcado SEM VALOR FISCAL internamente). }
  GerarDe('nfe_sem_protocolo.xml', Saida);
  AssertTrue(FileExists(Saida));
  AssertEquals('%PDF', LerInicio(Saida));
  AssertTrue(TamArquivo(Saida) > 500);
end;

initialization
  RegisterTest(TAcbrFacadeTests);

end.
