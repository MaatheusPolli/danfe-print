@echo off
rem Build local via linha de comando.
rem
rem  1) Alvo FPC (console, sem VCL, sem licenca): sh test-fpc.sh 
rem     Requer fpc no PATH e third_party\FPDF-Pascal clonado.
rem  2) Alvo Delphi (GUI + testes): este script. Requer dcc32 no PATH e
rem     Delphi com compilacao por linha de comando (Trial/CE nao suporta).
rem     Defina ACBR_DIR para compilar com ACBr real; sem ele usa o gerador FPDF.
setlocal
if not exist bin mkdir bin
set UNITS=src\App;src\Domain;src\Services;src\Infra;src\CLI;src\UI
set UNITS=%UNITS%;third_party\FPDF-Pascal\source
set NS=System;Winapi;Vcl;Xml;Data;System.Win
set DEFS=
if defined ACBR_DIR (
  set UNITS=%UNITS%;%ACBR_DIR%\Fontes\ACBrComum;%ACBR_DIR%\Fontes\ACBrDFe;%ACBR_DIR%\Fontes\ACBrDFe\ACBrNFe
  set DEFS=-DUSE_ACBR
)
dcc32 -B -Q -NS%NS% -U%UNITS% -E bin -NU bin\dcu %DEFS% DanfePrint.dpr || exit /b 1
if exist tests\DanfePrintTests.dpr (
  dcc32 -B -Q -NS%NS% -U%UNITS% -E bin -NU bin\dcu -DCONSOLE_TESTRUNNER tests\DanfePrintTests.dpr || exit /b 1
)
endlocal
