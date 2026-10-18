# Instalação do ACBr

O DanfePrint usa apenas os **fontes** do ACBr (ACBrNFe + DANFE). Não é necessário instalar os pacotes na IDE para compilar pela linha de comando; basta apontar o caminho dos fontes.

## 1. Obter os fontes

Pelo repositório SVN oficial do Projeto ACBr (verifique o endereço atual em projetoacbr.com.br):

```bat
svn checkout https://svn.code.sf.net/p/acbr/code/trunk2 C:\ACBr
```

> O `boss.json` do projeto referencia o ACBr como dependência; confirme o endereço do repositório antes de rodar `boss install`.

## 2. Compilar o DanfePrint com ACBr

```bat
set ACBR_DIR=C:\ACBr
build.bat
```

Com `ACBR_DIR` definido o build ativa a diretiva `USE_ACBR` e adiciona ao search path as pastas `Fontes\ACBrComum`, `Fontes\ACBrDFe` e `Fontes\ACBrDFe\ACBrNFe`. Outras pastas podem ser necessárias conforme o motor de relatório escolhido (FastReport ou Fortes).

## 3. DLLs em tempo de execução

Documentar aqui as DLLs necessárias (OpenSSL/libxml2, conforme a configuração de `SSLLib`/`SSLXmlSignLib`) quando a facade estiver implementada.

## Pela IDE

1. Abra `DanfePrint.dpr` no Delphi e salve para gerar o `.dproj`.
2. Em *Project > Options > Delphi Compiler*: adicione as pastas do ACBr em *Search path* e `USE_ACBR` em *Conditional defines*.
