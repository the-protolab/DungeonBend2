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

bun "$cli" bend_root/dungeon/app/main.bend --to-chk > /dev/null
bun "$cli" bend_root/dungeon/run/main.bend --to-chk > /dev/null
