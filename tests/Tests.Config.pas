unit Tests.Config;

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

uses
  fpcunit, testregistry;

type
  TConfigTests = class(TTestCase)
  published
    procedure ArquivoInexistenteUsaPadroes;
    procedure SalvaECarrega;
    procedure OrientacaoInvalidaVoltaParaRetrato;
  end;

implementation

uses
  SysUtils, Classes, Domain.Danfe, App.Config, Tests.Helpers;

procedure TConfigTests.ArquivoInexistenteUsaPadroes;
var
  C: TAppConfig;
begin
  C := TAppConfig.Create(TempDir('config') + 'nao-existe.ini');
  try
    C.Carregar;
    AssertEquals('', C.UltimaPasta);
    AssertTrue(C.Orientacao = doRetrato);
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
    AssertEquals('c:\notas', C.UltimaPasta);
    AssertEquals('c:\pdfs', C.UltimaPastaSaida);
    AssertEquals('c:\logo.png', C.DanfeOptions.LogoFile);
    AssertTrue(C.DanfeOptions.Orientacao = doPaisagem);
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
    AssertTrue(C.Orientacao = doRetrato);
  finally
    C.Free;
  end;
end;

initialization
  RegisterTest(TConfigTests);

end.
