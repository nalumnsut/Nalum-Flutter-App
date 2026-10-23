#!/usr/bin/env bash
# Regenerates every generated file in the repo. Generated files are committed
# (docs/ARCHITECTURE.md §6), so run this after changing a DTO or an .arb file.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "==> build_runner: nalum_api"
(cd packages/nalum_api && dart run build_runner build --delete-conflicting-outputs)

echo "==> gen-l10n: app"
(cd apps/mobile && flutter gen-l10n)
