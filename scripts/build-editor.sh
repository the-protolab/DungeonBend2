#!/bin/sh
set -eu

bun scripts/build.ts src/Editor/main.bend editor/index.html
