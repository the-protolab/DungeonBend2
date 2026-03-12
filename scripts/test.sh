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

out=$(bun "$cli" src/test/regression.bend --no-strict) || exit 1
printf '%s\n' "$out"
last=$(printf '%s\n' "$out" | tail -n 1)
if [ "$last" != "1" ]; then
  printf 'Expected final line 1, got %s\n' "$last" >&2
  exit 1
fi
