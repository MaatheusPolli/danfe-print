# DanfePrint

Gera o DANFE (NF-e modelo 55) e o DANFE NFC-e (modelo 65) em PDF a partir do XML autorizado, usando ACBr. Funciona como aplicativo gráfico (VCL) e como linha de comando para automação.

> Status: domínio, validação de XML, CLI e lote implementados e testados. Facade ACBr e GUI em andamento.

## Uso pela linha de comando

```
DanfePrint --in nota.xml [--out nota.pdf] [--modo retrato|paisagem] [--logo logo.png] [--quiet]
DanfePrint --in-dir pasta [--out-dir saida] [opções]
DanfePrint --help
```

| Código de saída | Significado |
|---|---|
| 0 | sucesso |
| 1 | erro de processamento (XML inválido, falha ao gerar, lote com erros) |
| 2 | erro de uso (argumentos inválidos) |

No modo lote é gerado um PDF por XML e um `relatorio.csv` (separador `;`, UTF-8) com o status de cada arquivo. Um XML com erro não interrompe o lote.

XMLs `NFe` sem protocolo de autorização são aceitos e o DANFE sai marcado como **SEM VALOR FISCAL**.

## Arquitetura

```
UI (VCL) ──┐
CLI      ──┼──► IDanfeService ──► IXmlLoader (validação)
           │                  └─► IDanfeGenerator (Infra.AcbrFacade — única unidade que conhece o ACBr)
           └──► IBatchProcessor, TAppConfig (INI), ILogService (log diário)
```

| Pasta | Conteúdo |
|---|---|
| `src/Domain` | tipos (`TDanfeOptions`, `TDanfeResult`), interfaces e mensagens |
| `src/Services` | `XmlLoader`, `Danfe` (orquestrador), `Batch`, `Log` |
| `src/Infra` | adaptador XML, sistema de arquivos, facade ACBr |
| `src/CLI` | parser de argumentos e runner |
| `src/App` | bootstrap GUI×CLI, configuração INI |
| `tests` | testes unitários e fixtures anonimizadas |

## Testes

As camadas sem UI e sem ACBr compilam também com **Free Pascal 3.2+** (`{$mode delphi}`), o que permite rodar a suíte sem licença do Delphi:

```bash
sh test-fpc.sh
```

A suíte DUnitX para Delphi será adicionada junto com a GUI.

A CI (`.github/workflows/ci.yml`) roda esta suíte FPC em runners Linux. A biblioteca **FPDF-Pascal** precisa estar clonada em `third_party/FPDF-Pascal` (é o que o `test-fpc.sh` e o workflow fazem).

Executável de linha de comando com FPC: `DanfePrintFpc.lpr` (gera PDF sem VCL).

## Compilação (Delphi)

Requer Delphi 12+ com compilação por linha de comando (edições Community Trial não suportam `dcc32` pela linha de comando — nesse caso compile pela IDE) e o ACBr instalado. Veja [docs/instalacao-acbr.md](docs/instalacao-acbr.md).

```bat
set ACBR_DIR=C:\ACBr
build.bat
```

## Licença

Este projeto usa **licença dupla**. O texto completo está em [LICENSE](LICENSE).

- **Uso pessoal, educacional e não comercial:** livre, nos termos da licença MIT (mantenha o aviso de copyright).
- **Uso comercial:** exige licença comercial. Isso inclui usar em produto ou serviço comercial, vender acesso ou derivados, usar em atividades com fins lucrativos e implantar em empresas.

Contato para licença comercial: ma.polli@hotmail.com
