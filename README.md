# DanfePrint

Gera o DANFE (NF-e modelo 55) e o DANFE NFC-e (modelo 65) em PDF a partir do XML autorizado, usando ACBr. Funciona como aplicativo grÃ¡fico (VCL) e como linha de comando para automaÃ§Ã£o.

> Status: domÃ­nio, validaÃ§Ã£o de XML, CLI e lote implementados e testados. Facade ACBr e GUI em andamento â€” veja [planejamento.md](planejamento.md).

## Uso pela linha de comando

```
DanfePrint --in nota.xml [--out nota.pdf] [--modo retrato|paisagem] [--logo logo.png] [--quiet]
DanfePrint --in-dir pasta [--out-dir saida] [opÃ§Ãµes]
DanfePrint --help
```

| CÃ³digo de saÃ­da | Significado |
|---|---|
| 0 | sucesso |
| 1 | erro de processamento (XML invÃ¡lido, falha ao gerar, lote com erros) |
| 2 | erro de uso (argumentos invÃ¡lidos) |

No modo lote Ã© gerado um PDF por XML e um `relatorio.csv` (separador `;`, UTF-8) com o status de cada arquivo. Um XML com erro nÃ£o interrompe o lote.

XMLs `NFe` sem protocolo de autorizaÃ§Ã£o sÃ£o aceitos e o DANFE sai marcado como **SEM VALOR FISCAL**.

## Arquitetura

```
UI (VCL) â”€â”€â”
CLI      â”€â”€â”¼â”€â”€â–º IDanfeService â”€â”€â–º IXmlLoader (validaÃ§Ã£o)
           â”‚                  â””â”€â–º IDanfeGenerator (Infra.AcbrFacade â€” Ãºnica unidade que conhece o ACBr)
           â””â”€â”€â–º IBatchProcessor, TAppConfig (INI), ILogService (log diÃ¡rio)
```

| Pasta | ConteÃºdo |
|---|---|
| `src/Domain` | tipos (`TDanfeOptions`, `TDanfeResult`), interfaces e mensagens |
| `src/Services` | `XmlLoader`, `Danfe` (orquestrador), `Batch`, `Log` |
| `src/Infra` | adaptador XML, sistema de arquivos, facade ACBr |
| `src/CLI` | parser de argumentos e runner |
| `src/App` | bootstrap GUIÃ—CLI, configuraÃ§Ã£o INI |
| `tests` | testes unitÃ¡rios e fixtures anonimizadas |

## Testes

As camadas sem UI e sem ACBr compilam tambÃ©m com **Free Pascal 3.2+** (`{$mode delphi}`), o que permite rodar a suÃ­te sem licenÃ§a do Delphi:

```bash
sh test-fpc.sh
```

A suÃ­te DUnitX para Delphi serÃ¡ adicionada junto com a GUI.

## CompilaÃ§Ã£o (Delphi)

Requer Delphi 12+ com compilaÃ§Ã£o por linha de comando (ediÃ§Ãµes Community Trial nÃ£o suportam `dcc32` pela linha de comando â€” nesse caso compile pela IDE) e o ACBr instalado. Veja [docs/instalacao-acbr.md](docs/instalacao-acbr.md).

```bat
set ACBR_DIR=C:\ACBr
build.bat
```


## Licença

### Uso Pessoal
Este projeto é licenciado sob a **Licença MIT** para uso pessoal, educacional e não comercial.

### Uso Comercial
Se você deseja usar este projeto comercialmente, deve obter uma licença comercial do autor.

**Uso comercial inclui:**
- Incorporar em um produto comercial
- Oferecer como serviço
- Usar em atividades com fins lucrativos
- Implantação empresarial

**Para obter uma licença comercial:**
Email: ma.polli@hotmail.com
