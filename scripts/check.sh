#!/bin/sh
set -eu

if [ -f ../Bend2/bend-ts/src/CLI.ts ]; then
  cli=../Bend2/bend-ts/src/CLI.ts
elif [ -f ../Bend2/src/ts/CLI.ts ]; then
  cli=../Bend2/src/ts/CLI.ts
else
  echo "Bend2 CLI not found. Expected ../Bend2/bend-ts/src/CLI.ts or ../Bend2/src/ts/CLI.ts" >&2
  exit 1
fi

bun "$cli" src/main.bend --to-chk --no-strict > /dev/null
bun "$cli" src/test/regression.bend --to-chk --no-strict > /dev/null
