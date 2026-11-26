#!/bin/sh
# Compila e roda a suite fpcunit com Free Pascal (camadas sem VCL/ACBr).
set -e
cd "$(dirname "$0")"
FPC=${FPC:-fpc}
mkdir -p bin/fpc-units
"$FPC" -Mdelphi -Scghi -O1 -gl -vewn -FUbin/fpc-units -FEbin \
  -Fusrc/App -Fusrc/Domain -Fusrc/Services -Fusrc/Infra -Fusrc/CLI -Futests \
  -Futhird_party/FPDF-Pascal/source -Fithird_party/FPDF-Pascal/source \
  tests/DanfePrintTestsFpc.lpr
exe=bin/DanfePrintTestsFpc
[ -f "$exe.exe" ] && exe="$exe.exe"
"$exe" "$@"
