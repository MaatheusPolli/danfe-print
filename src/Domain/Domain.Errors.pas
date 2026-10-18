unit Domain.Errors;

{ Mensagens centralizadas (facilita revisao e futura traducao). }

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

uses
  SysUtils;

type
  EDanfeError = class(Exception);

resourcestring
  SArquivoNaoEncontrado = 'Arquivo n'#$E3'o encontrado: %s';
  SXmlMalFormado = 'XML mal formado: %s';
  SRaizInvalida = 'Raiz do XML deve ser <nfeProc> ou <NFe>, encontrado <%s>';
  SInfNFeAusente = 'Elemento <infNFe> n'#$E3'o encontrado';
  SChaveAusente = 'Atributo Id de <infNFe> ausente ou sem prefixo "NFe"';
  SChaveInvalida = 'Chave de acesso inv'#$E1'lida: %s';
  SModeloDesconhecido = 'Modelo de documento n'#$E3'o suportado: %s (esperado 55 ou 65)';
  SModeloDivergente = 'Modelo em <ide><mod> (%s) diverge do modelo da chave (%s)';
  SPastaNaoEncontrada = 'Pasta n'#$E3'o encontrada: %s';
  SNenhumXml = 'Nenhum arquivo .xml encontrado em: %s';
  SErroInesperado = 'Erro inesperado: %s';
  SErroGravarRelatorio = 'N'#$E3'o foi poss'#$ED'vel gravar o relat'#$F3'rio: %s';
  SErroGeracaoPdf = 'Falha ao gerar o PDF: %s';

implementation

end.
