#!/usr/bin/env bash
# The gate (AGENTS.md "Verifying changes"). Zero tolerance: a format diff, an
# analyzer info, a layer-boundary violation, a broken doc reference, stale
# generated code or a failing test all fail it. CI runs exactly this script,
# so "green locally" means "green in CI".
#
# Usage:  bash tool/check.sh          full gate (run before every push)
#         bash tool/check.sh --fast   skips the codegen-freshness step
#
# Windows: run from Git Bash or WSL, not cmd/PowerShell (AGENTS.md "Platform quirks").
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

fast=false
if [[ "${1:-}" == "--fast" ]]; then fast=true; fi

step() { printf '\n==> %s\n' "$*"; }

# Hand-written Dart files only: generated code is formatted by its generator.
dart_sources() {
  find apps packages tool -name '*.dart' \
    -not -path '*/.dart_tool/*' -not -path '*/build/*' \
    -not -name '*.g.dart' -not -name '*.freezed.dart' \
    -not -path '*/l10n/generated/*' -print0
}

generated_fingerprint() {
  find apps packages \( -name '*.g.dart' -o -name '*.freezed.dart' -o -path '*/l10n/generated/*.dart' \) \
    -not -path '*/.dart_tool/*' -not -path '*/build/*' -print0 \
    | sort -z | xargs -0 cksum
}

step "Resolve dependencies"
if [[ "${CI:-}" == "true" ]]; then
  # CI must build exactly what was reviewed.
  flutter pub get --enforce-lockfile > /dev/null
else
  flutter pub get > /dev/null
fi

step "Format"
dart_sources | xargs -0 dart format --output=none --set-exit-if-changed

step "Analyze (infos are fatal)"
flutter analyze --fatal-infos --fatal-warnings

step "Architecture boundaries (docs/ARCHITECTURE.md §4)"
dart run tool/check_architecture.dart

step "Docs: section references, links, placeholders"
dart run tool/check_docs.dart

if [[ "$fast" == false ]]; then
  step "Generated code is up to date"
  before="$(generated_fingerprint)"
  bash tool/codegen.sh > /dev/null
  after="$(generated_fingerprint)"
  if [[ "$before" != "$after" ]]; then
    echo "Codegen changed generated files. Run 'bash tool/codegen.sh' and commit the result." >&2
    diff <(echo "$before") <(echo "$after") >&2 || true
    exit 1
  fi
fi

step "Tests: nalum_api"
(cd packages/nalum_api && dart test)

step "Tests: nalum_ui"
(cd packages/nalum_ui && flutter test)

step "Tests: app"
(cd apps/mobile && flutter test)

printf '\nAll checks passed.\n'
