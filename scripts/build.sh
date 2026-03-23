#!/bin/sh
set -eu

out_dir="${OUT_DIR:-dist}"
out_html="$out_dir/index.html"
out_assets="$out_dir/assets"

mkdir -p "$out_assets"

if command -v bend >/dev/null 2>&1; then
  bend src/main.bend --to-web --no-strict > "$out_html"
elif [ -f ../Bend2/bend-ts/src/CLI.ts ]; then
  bun ../Bend2/bend-ts/src/CLI.ts src/main.bend --to-web --no-strict > "$out_html"
elif [ -f ../Bend2/src/ts/CLI.ts ]; then
  bun ../Bend2/src/ts/CLI.ts src/main.bend --to-web --no-strict > "$out_html"
else
  echo "Bend2 CLI not found. Install bend globally or keep ../Bend2 next to this repo." >&2
  exit 1
fi

cp assets/* "$out_assets"/
touch "$out_dir/.nojekyll"
printf '%s\n' "Built $out_html"
