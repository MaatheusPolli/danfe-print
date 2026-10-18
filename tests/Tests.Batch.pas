unit Tests.Batch;

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

uses
  fpcunit, testregistry, Domain.Interfaces, Tests.Mocks;

type
  TBatchTests = class(TTestCase)
  private
    FGen: TFakeGenerator;
    FGenRef: IDanfeGenerator;
    FBatch: IBatchProcessor;
    FIn, FOut: string;
    procedure Copiar(const AFixture: string);
    procedure LimparPasta(const ADir: string);
  protected
    procedure SetUp; override;
  published
    procedure TresXmlsUmInvalido;
    procedure RelatorioCsv;
    procedure ExcecaoNaoAbortaLote;
    procedure PastaInexistente;
    procedure PastaVaziaGeraRelatorioVazio;
    procedure SaidaPadraoNaPastaDeEntrada;
    procedure CsvEscapaAspas;
  end;

implementation

uses
  SysUtils, Classes, Domain.Danfe, Service.Danfe, Service.XmlLoader, Service.Log,
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

procedure TBatchTests.SetUp;
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
  AssertEquals(3, Length(R));
  AssertEquals(2, FGen.Chamadas);
  // ordem alfabetica: invalido_chave, nfce_autorizada, nfe_autorizada
  AssertFalse(R[0].Success);
  AssertTrue(R[1].Success);
  AssertTrue(R[2].Success);
  AssertTrue(FileExists(FOut + 'nfe_autorizada.pdf'));
  AssertTrue(FileExists(FOut + 'nfce_autorizada.pdf'));
  AssertFalse(FileExists(FOut + 'invalido_chave.pdf'));
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
    AssertEquals(3, L.Count);
    AssertTrue(Pos('arquivo;status;pdf;mensagem', L[0]) > 0);
    AssertTrue(Pos('"invalido_chave.xml";"ERRO";"";', L[1]) > 0);
    AssertTrue(Pos('"nfe_autorizada.xml";"OK";', L[2]) > 0);
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
  AssertEquals(2, Length(R));
  AssertEquals(2, FGen.Chamadas);
  AssertFalse(R[0].Success);
  AssertFalse(R[1].Success);
end;

procedure TBatchTests.PastaInexistente;
var
  R: TArray<TDanfeResult>;
begin
  R := FBatch.GerarLote(FIn + 'nao-existe', FOut, TDanfeOptions.Default);
  AssertEquals(1, Length(R));
  AssertFalse(R[0].Success);
  AssertTrue(Pos('encontrada', R[0].ErrorMessage) > 0);
end;

procedure TBatchTests.PastaVaziaGeraRelatorioVazio;
var
  R: TArray<TDanfeResult>;
begin
  R := FBatch.GerarLote(FIn, FOut, TDanfeOptions.Default);
  AssertEquals(0, Length(R));
  AssertTrue(FileExists(FOut + NOME_RELATORIO));
end;

procedure TBatchTests.SaidaPadraoNaPastaDeEntrada;
begin
  Copiar('nfe_autorizada.xml');
  FBatch.GerarLote(FIn, '', TDanfeOptions.Default);
  AssertTrue(FileExists(FIn + 'nfe_autorizada.pdf'));
  AssertTrue(FileExists(FIn + NOME_RELATORIO));
end;

procedure TBatchTests.CsvEscapaAspas;
begin
  AssertEquals('"a ""b"" c"', CsvCampo('a "b" c'));
end;

initialization
  RegisterTest(TBatchTests);

end.
