# DungeonBend

Single-file Bend2 dungeon crawler. The app now lives in [`src/main.bend`](./src/main.bend), uses the official Bend2 prelude directly, and no longer keeps local copies of `App`, `HTML`, `Attr`, `Char`, `List`, `String`, or `U32`.

## Requirements

- [Bun](https://bun.sh)
- A sibling checkout of `Bend2` at `../Bend2`

## Layout

- `src/main.bend`: whole application in one Bend file
- `src/test/regression.bend`: consolidated regression suite
- `assets/`: images used by the UI

## Commands

```bash
sh scripts/check.sh
sh scripts/test.sh
sh scripts/build.sh
```

- `check`: typechecks the app and the regression file
- `test`: runs the consolidated regression suite and expects a final `1`
- `build`: emits `dist/index.html` plus `dist/assets/*`

The current Bend2 CLI in `../Bend2` requires `--no-strict` for this codebase because the game logic still uses expression-style matches like `x === 0` and `a < b`. The scripts already pass that flag.

If you have a global `bend` command installed, the direct equivalents are:

```bash
bend src/main.bend --to-web --no-strict
bend src/test/regression.bend --no-strict
```
