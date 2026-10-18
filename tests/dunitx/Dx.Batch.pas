unit Dx.Batch;

interface

uses
  DUnitX.TestFramework, Domain.Interfaces, Tests.Mocks;

type
  [TestFixture]
  TBatchTests = class
  private
    FGen: TFakeGenerator;
    FGenRef: IDanfeGenerator;
    FBatch: IBatchProcessor;
    FIn, FOut: string;
    procedure Copiar(const AFixture: string);
    procedure LimparPasta(const ADir: string);
  public
    [Setup] procedure Setup;
    [Test] procedure TresXmlsUmInvalido;
    [Test] procedure RelatorioCsv;
    [Test] procedure ExcecaoNaoAbortaLote;
    [Test] procedure PastaInexistente;
    [Test] procedure PastaVaziaGeraRelatorioVazio;
    [Test] procedure SaidaPadraoNaPastaDeEntrada;
    [Test] procedure CsvEscapaAspas;
  end;

implementation

uses
  System.SysUtils, System.Classes, Domain.Danfe, Service.Danfe, Service.XmlLoader, Service.Log,
  Service.Batch, Tests.Helpers;

procedure TBatchTests.LimparPasta(const ADir: string);
var
  SR: TSearchRec;
begin
  if FindFirst(ADir + '*.*', faAnyFile, SR) = 0 then
  try
    repeat
      if (SR.Attr and faDirectory) = 0 then
        DeleteFile(ADir + SR.Name);
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;

procedure TBatchTests.Copiar(const AFixture: string);
var
  S: TMemoryStream;
begin
  S := TMemoryStream.Create;
  try
    S.LoadFromFile(FixturePath(AFixture));
    S.SaveToFile(FIn + AFixture);
  finally
    S.Free;
  end;
end;

procedure TBatchTests.Setup;
var
  Service: IDanfeService;
begin
  FGen := TFakeGenerator.Create;
  FGenRef := FGen;
  Service := TDanfeService.Create(TXmlLoader.Create, FGenRef, TNullLog.Create);
  FBatch := TBatchProcessor.Create(Service, TNullLog.Create);
  FIn := TempDir('batch-in');
  FOut := TempDir('batch-out');
  LimparPasta(FIn);
  LimparPasta(FOut);
end;

procedure TBatchTests.TresXmlsUmInvalido;
var
  R: TArray<TDanfeResult>;
begin
  Copiar('nfe_autorizada.xml');
  Copiar('nfce_autorizada.xml');
  Copiar('invalido_chave.xml');
  R := FBatch.GerarLote(FIn, FOut, TDanfeOptions.Default);
  Assert.AreEqual(3, Length(R));
  Assert.AreEqual(2, FGen.Chamadas);
  // ordem alfabetica: invalido_chave, nfce_autorizada, nfe_autorizada
  Assert.IsFalse(R[0].Success);
  Assert.IsTrue(R[1].Success);
  Assert.IsTrue(R[2].Success);
  Assert.IsTrue(FileExists(FOut + 'nfe_autorizada.pdf'));
  Assert.IsTrue(FileExists(FOut + 'nfce_autorizada.pdf'));
  Assert.IsFalse(FileExists(FOut + 'invalido_chave.pdf'));
end;

procedure TBatchTests.RelatorioCsv;
var
  L: TStringList;
begin
  Copiar('nfe_autorizada.xml');
  Copiar('invalido_chave.xml');
  FBatch.GerarLote(FIn, FOut, TDanfeOptions.Default);
  L := TStringList.Create;
  try
    L.LoadFromFile(FOut + NOME_RELATORIO);
    Assert.AreEqual(3, L.Count);
    Assert.IsTrue(Pos('arquivo;status;pdf;mensagem', L[0]) > 0);
    Assert.IsTrue(Pos('"invalido_chave.xml";"ERRO";"";', L[1]) > 0);
    Assert.IsTrue(Pos('"nfe_autorizada.xml";"OK";', L[2]) > 0);
  finally
    L.Free;
  end;
end;

procedure TBatchTests.ExcecaoNaoAbortaLote;
var
  R: TArray<TDanfeResult>;
begin
  Copiar('nfe_autorizada.xml');
  Copiar('nfce_autorizada.xml');
  FGen.LevantarExcecao := True;
  R := FBatch.GerarLote(FIn, FOut, TDanfeOptions.Default);
  Assert.AreEqual(2, Length(R));
  Assert.AreEqual(2, FGen.Chamadas);
  Assert.IsFalse(R[0].Success);
  Assert.IsFalse(R[1].Success);
end;

procedure TBatchTests.PastaInexistente;
var
  R: TArray<TDanfeResult>;
begin
  R := FBatch.GerarLote(FIn + 'nao-existe', FOut, TDanfeOptions.Default);
  Assert.AreEqual(1, Length(R));
  Assert.IsFalse(R[0].Success);
  Assert.IsTrue(Pos('encontrada', R[0].ErrorMessage) > 0);
end;

procedure TBatchTests.PastaVaziaGeraRelatorioVazio;
var
  R: TArray<TDanfeResult>;
begin
  R := FBatch.GerarLote(FIn, FOut, TDanfeOptions.Default);
  Assert.AreEqual(0, Length(R));
  Assert.IsTrue(FileExists(FOut + NOME_RELATORIO));
end;

procedure TBatchTests.SaidaPadraoNaPastaDeEntrada;
begin
  Copiar('nfe_autorizada.xml');
  FBatch.GerarLote(FIn, '', TDanfeOptions.Default);
  Assert.IsTrue(FileExists(FIn + 'nfe_autorizada.pdf'));
  Assert.IsTrue(FileExists(FIn + NOME_RELATORIO));
end;

procedure TBatchTests.CsvEscapaAspas;
begin
  Assert.AreEqual('"a ""b"" c"', CsvCampo('a "b" c'));
end;

initialization
  TDUnitX.RegisterTestFixture(TBatchTests);

end.
