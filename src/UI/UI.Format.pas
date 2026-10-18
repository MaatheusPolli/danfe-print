unit UI.Format;

{ Regras de apresentacao da GUI sem dependencia de VCL: testaveis em qualquer ambiente. }

interface

uses
  Domain.Danfe;

{ Linha do relatorio exibida no lote: "OK ..." ou "ERRO ...: mensagem". }
function LinhaResultadoLote(const R: TDanfeResult): string;

{ Resumo final do lote (mesmo texto do CLI). }
function ResumoLote(AOk, AErros: Integer): string;

{ Mapeia a orientacao para o indice do combo (0 = retrato, 1 = paisagem). }
function IndiceOrientacao(AValor: TDanfeOrientacao): Integer;
function OrientacaoDoIndice(AIndice: Integer): TDanfeOrientacao;

{ Lote so pode rodar com entrada e saida preenchidas (espacos nao contam). }
function EntradasPreenchidas(const AEntrada, ASaida: string): Boolean;

implementation

uses
  SysUtils;

function LinhaResultadoLote(const R: TDanfeResult): string;
begin
  if R.Success then
    Result := 'OK    ' + ExtractFileName(R.XmlFile)
  else
    Result := 'ERRO  ' + ExtractFileName(R.XmlFile) + ': ' + R.ErrorMessage;
end;

function ResumoLote(AOk, AErros: Integer): string;
begin
  Result := Format('Lote conclu'#$ED'do: %d sucesso(s), %d erro(s)', [AOk, AErros]);
end;

function IndiceOrientacao(AValor: TDanfeOrientacao): Integer;
begin
  Result := Ord(AValor);
end;

function OrientacaoDoIndice(AIndice: Integer): TDanfeOrientacao;
begin
  if AIndice = Ord(doPaisagem) then
    Result := doPaisagem
  else
    Result := doRetrato;
end;

function EntradasPreenchidas(const AEntrada, ASaida: string): Boolean;
begin
  Result := (Trim(AEntrada) <> '') and (Trim(ASaida) <> '');
end;

end.
