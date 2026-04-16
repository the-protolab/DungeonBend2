#!/bin/sh
set -eu

out_dir="${OUT_DIR:-dist}"
out_html="$out_dir/index.html"
out_assets="$out_dir/assets"

mkdir -p "$out_assets"

bun -e 'import { generateDungeonConfig } from "./scripts/dungeon-data.ts"; await generateDungeonConfig(process.cwd());'

if [ -f ../Bend2/bend-ts/src/Bend.ts ]; then
  bun scripts/build.ts src/main.bend "$out_html"
elif command -v bend >/dev/null 2>&1; then
  bend src/main.bend --to-web > "$out_html"
else
  echo "Bend2 CLI not found. Install bend globally or keep ../Bend2 next to this repo." >&2
  exit 1
fi

cp assets/* "$out_assets"/
touch "$out_dir/.nojekyll"
printf '%s\n' "Built $out_html"
