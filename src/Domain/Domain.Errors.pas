unit Domain.Errors;

{ Mensagens centralizadas (facilita revisao e futura traducao). }

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

uses
  SysUtils;

type
  EDanfeError = class(Exception);

resourcestring
  SArquivoNaoEncontrado = 'Arquivo não encontrado: %s';
  SXmlMalFormado = 'XML mal formado: %s';
  SRaizInvalida = 'Raiz do XML deve ser <nfeProc> ou <NFe>, encontrado <%s>';
  SInfNFeAusente = 'Elemento <infNFe> não encontrado';
  SChaveAusente = 'Atributo Id de <infNFe> ausente ou sem prefixo "NFe"';
  SChaveInvalida = 'Chave de acesso inválida: %s';
  SModeloDesconhecido = 'Modelo de documento não suportado: %s (esperado 55 ou 65)';
  SModeloDivergente = 'Modelo em <ide><mod> (%s) diverge do modelo da chave (%s)';
  SPastaNaoEncontrada = 'Pasta não encontrada: %s';
  SNenhumXml = 'Nenhum arquivo .xml encontrado em: %s';
  SErroInesperado = 'Erro inesperado: %s';
  SErroGravarRelatorio = 'Não foi possível gravar o relatório: %s';
  SErroGeracaoPdf = 'Falha ao gerar o PDF: %s';

implementation

end.
