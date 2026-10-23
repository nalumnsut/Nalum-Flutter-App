<!-- Title = the squash commit: `type(scope): summary`, ≤ 50 chars, no period (docs/WORKFLOW.md §6). -->

## What and why

<!-- One or two sentences. -->

## How it was verified

<!-- Tick what you actually ran (AGENTS.md "Verifying changes"). "Should work" is not verified. -->

- [ ] `bash tool/check.sh` passes locally
- [ ] Ran on Android (dev flavor): device / emulator model:
- [ ] iOS checked (CI `ios` label, TestFlight or shared Mac) — or not needed because:
- [ ] Loading, empty, error and offline states seen
- [ ] Dark mode, 200 % text, small screen checked (UI changes)

## Screenshots

<!-- UI changes: light and dark. Use invented test accounts only, never real alumni. -->

## Checklist

- [ ] No secrets, tokens or personal data in code, logs, tests or screenshots
- [ ] Commits are short and have no co-author or AI-attribution lines
- [ ] Docs updated in this PR (or nothing they describe changed)
- [ ] New user-facing text is in `app_en.arb`
- [ ] New data collected / permission requested → `docs/STORE_LISTING.md` §5 updated (or none)
- [ ] Needs a backend change? `docs/API.md` §4 item id:
