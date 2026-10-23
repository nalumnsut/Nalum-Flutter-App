# AGENTS.md — NALUM mobile app

Operating manual for anyone working in this repo, human or AI agent. It
outranks habits from other projects. If something here is wrong, fix this
file in the same PR as the code.

---

## What this is

**NALUM** is the Flutter app (Android + iOS) for the NSUT Alumni Association,
the mobile companion to [alumni.nsut.ac.in](https://alumni.nsut.ac.in). Users
are NSUT **alumni, students and faculty**; admins keep using the website.

The app covers the website's dashboard: directory and connections, posts with
comments, events, chat (1:1 and communities), notifications, alumni
verification, queries and profile. Full inventory: [docs/PLAN.md §1](docs/PLAN.md).

Boundaries:

- **Server-authoritative client.** The backend (`nalumnsut/nalum`, being
  rewritten) owns all data and all rules. The app caches and displays; it
  never invents state. The only offline writes are queued chat messages
  ([docs/CHAT.md §4](docs/CHAT.md)).
- **Contract-first.** The app talks to the backend only through the contract
  in `packages/nalum_api` and [docs/API.md](docs/API.md). Backend changes are
  agreed there first.
- **Real people's data.** Profiles, locations, employers and private messages
  of real alumni. Privacy rules below are not optional.
- **Store-published.** Old versions stay installed for months, store review
  can take days, and identifiers (bundle id, signing key) are permanent.
  Prefer boring, reversible changes.
- **Rotating student team.** Every batch hands the repo to the next. Write
  code a second-year can understand after you graduate.

Status: **M0 (foundations)**. Auth state, routing guard, networking, design
system and the gate are real; feature screens are placeholders. Milestones:
[docs/PLAN.md §3](docs/PLAN.md).

---

## Read before working

| If your task touches… | Read first |
|---|---|
| Sign-in, tokens, sessions, gates (verify email, profile, alumni verification), account deletion | [docs/AUTH.md](docs/AUTH.md) |
| Calling an endpoint, adding a DTO, error codes, backend requests | [docs/API.md](docs/API.md) |
| A new screen, route, tab, deep link or push-tap target | [docs/NAVIGATION.md](docs/NAVIGATION.md) |
| A new feature folder, moving code between layers, providers | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| Chat, sockets, presence, typing, offline outbox | [docs/CHAT.md](docs/CHAT.md) |
| Push notifications, the notification list, preferences | [docs/NOTIFICATIONS.md](docs/NOTIFICATIONS.md) |
| Storing anything on the device (cache, prefs, secure storage) | [docs/STORAGE.md](docs/STORAGE.md) |
| Colors, type, spacing, shared widgets, dark mode, accessibility | [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md) |
| Writing or fixing tests | [docs/TESTING.md](docs/TESTING.md) |
| Branches, PRs, reviews, roles, task flow | [docs/WORKFLOW.md](docs/WORKFLOW.md) |
| Versioning, flavors, signing, CI/CD, shipping a build | [docs/RELEASING.md](docs/RELEASING.md) |
| Store listing, privacy forms, permissions, reviewer account | [docs/STORE_LISTING.md](docs/STORE_LISTING.md) |
| Scope, milestones, open questions | [docs/PLAN.md](docs/PLAN.md) |
| An architectural decision (new package, pattern, tool) | [docs/adr/](docs/adr/README.md) |

---

## Commands

Run from the repo root in **Git Bash or WSL** (not PowerShell; see quirks).

```bash
bash tool/check.sh           # THE gate. Must pass before every push. CI runs the same script.
bash tool/check.sh --fast    # Same, minus the codegen-freshness step.
bash tool/codegen.sh         # Regenerate *.g.dart, *.freezed.dart and l10n. Commit the output.
flutter pub get              # Resolves the whole workspace (one pubspec.lock at the root).
git config core.hooksPath tool/hooks   # Once per clone: enables the commit-message check.
```

First-time setup and running on your own phone (USB or wireless
debugging): [SETUP.md](SETUP.md).

Run the app (from `apps/mobile`):

```bash
flutter run --flavor dev --dart-define-from-file=config/dev.json          # Android emulator → local backend
flutter run --flavor dev --dart-define-from-file=config/local.json        # Physical phone via adb reverse (SETUP.md §5)
flutter run --dart-define-from-file=config/dev.json                       # iOS (no iOS flavors yet, docs/RELEASING.md §2)
flutter test test/app/router/auth_redirect_test.dart                      # One test file
flutter build apk --flavor dev --dart-define-from-file=config/dev.json    # Installable dev APK
```

Local backend: in the website repo run `npm run dev:up` (API on port 2478).
The Android emulator reaches your machine as `10.0.2.2`, which `config/dev.json`
already uses.

---

## Repository layout

```
nalum-app/
├── AGENTS.md                  # This manual. CLAUDE.md and .github/copilot-instructions.md point here.
├── SETUP.md                   # First-time setup; running on a phone over USB or Wi-Fi.
├── pubspec.yaml               # Workspace root: ties app + packages into one resolution and lockfile.
├── analysis_options.yaml      # The one lint config (very_good_analysis, infos fatal).
├── .fvmrc                     # Pinned Flutter version; CI reads it too.
├── tool/
│   ├── check.sh               # The gate: format, analyze, boundaries, docs, codegen, tests.
│   ├── codegen.sh             # Regenerates all generated code.
│   ├── check_architecture.dart# Enforces layer import rules (docs/ARCHITECTURE.md §4).
│   ├── check_docs.dart        # Verifies § references, Markdown links, no placeholders.
│   ├── check_commit_msg.sh    # Commit rules (short, conventional, no co-author/AI lines).
│   └── hooks/commit-msg       # Runs the commit check locally (core.hooksPath).
├── docs/                      # Subsystem specs with stable § anchors; adr/ holds decisions.
├── .github/                   # CI/CD workflows, PR template, Dependabot.
├── apps/mobile/               # The Flutter app (package nalum_app).
│   ├── config/                # Per-flavor build config for --dart-define-from-file. No secrets.
│   ├── android/ ios/          # Native projects. Flavors, signing, permissions live here.
│   ├── lib/
│   │   ├── main.dart          # Reads build config, calls bootstrap().
│   │   ├── bootstrap.dart     # Error hooks, ProviderScope. Firebase init goes here later.
│   │   ├── app/               # Composition root: MaterialApp, router, tab shell, provider overrides.
│   │   ├── core/              # Feature-agnostic infrastructure: env, network, storage, logging, failure text.
│   │   ├── features/<name>/   # One folder per product area, split into layers:
│   │   │   ├── domain/        #   Pure Dart models and rules. No Flutter, no I/O.
│   │   │   ├── data/          #   Repositories: API calls, DTO→domain mapping, caching.
│   │   │   ├── application/   #   Riverpod providers/notifiers. The feature's public API.
│   │   │   └── presentation/  #   Screens and widgets. Read providers, never call data/ directly.
│   │   └── l10n/              # app_en.arb (all user-facing text) + generated/ (do not edit).
│   └── test/                  # Mirrors lib/. helpers/ holds fakes and fixtures.
└── packages/
    ├── nalum_api/             # Pure-Dart backend contract: paths, error envelope, DTOs.
    └── nalum_ui/              # Design system: tokens from design.md, ThemeData, shared widgets.
```

Background and platform hooks (push, deep links, secure storage) live in
`core/` behind interfaces, so features stay testable without devices
([docs/ARCHITECTURE.md §3](docs/ARCHITECTURE.md)).

---

## Hard rules

Breaking one of these blocks a PR, whatever else it does well. Style
preferences are under "Conventions" instead.

### Privacy and personal data

1. **Never log or report personal data or secrets.** No tokens, passwords,
   OTPs, emails, phone numbers, message text or full response bodies in logs,
   crash reports, analytics, PR descriptions or test output. Use
   `AppLogger` and log ids and error codes only.
2. **Never show raw server text to users.** Map failures through
   `failureText()` to localized strings. Server messages can leak internals
   and whether an account exists.
3. **Real people stay out of the repo.** Fixtures, screenshots, seed data and
   bug reports use made-up people. Never paste production or website-DB data
   into code, tests or PRs.
4. **No tracking SDKs.** No advertising or cross-app tracking SDKs, ever. Any
   new third-party SDK needs an ADR approved in review, because it
   changes the store privacy answers.
5. **Declared data stays true.** Collecting a new kind of data or requesting a
   new permission means updating [docs/STORE_LISTING.md §5](docs/STORE_LISTING.md)
   in the same PR.

### Security

1. **Tokens:** the refresh token lives only in `TokenStore` (Keychain /
   Keystore). The access token lives only in memory. Neither ever goes into
   shared_preferences, files, the database, logs or URLs.
2. **No secrets in the repo.** Everything in `config/*.json` and the app
   binary is public. Keystores, `key.properties`, service-account JSON and
   App Store Connect keys live in GitHub secrets and the org vault
   ([docs/RELEASING.md §4](docs/RELEASING.md)).
3. **HTTPS only** in release builds. Cleartext HTTP is allowed only in the
   debug manifest for the local backend.
4. **Links are untrusted input.** Deep links, push routes and notification
   `actionUrl`s go through `appLocationForLink()` before reaching the router.
5. **One refresh path.** Auth endpoints use `authDioProvider`; everything else
   uses `apiDioProvider`. Never write a second token-refresh mechanism
   ([docs/AUTH.md §3.3](docs/AUTH.md)).

### API etiquette

1. Every path is declared in `nalum_api`'s `ApiPaths`. No URL strings in features.
2. Repositories throw `AppFailure` only. A `DioException` never escapes `data/`.
3. Parse defensively: unknown roles, enum values and error codes from a newer
   backend must not crash an older app.
4. Code that depends on a legacy backend quirk says so in a comment citing
   [docs/API.md §5](docs/API.md), so it can be deleted when the backend is fixed.
5. Lists are paginated; never fetch unbounded collections. No retry loops on
   429, no polling faster than every 30 s. Realtime data comes from the socket.
6. The app never ships against an endpoint that isn't on the website repo's
   integration branch (`ctest`). New endpoints are requested as described in
   [docs/API.md §1](docs/API.md).

### Architecture boundaries

Enforced by `tool/check_architecture.dart` ([docs/ARCHITECTURE.md §4](docs/ARCHITECTURE.md)):

1. `core/` never imports `features/` or `app/`.
2. `features/*/domain/` is pure Dart: no Flutter, no I/O, no packages beyond `meta`/`collection`.
3. `presentation/` never imports `dio`, `nalum_api` or any `data/` folder.
4. A feature uses another feature only through its `domain/` or `application/`.
5. `nalum_api` has no Flutter. `nalum_ui` has no app code, networking or state management.
6. Auth-based navigation decisions live only in `authRedirect()`.

### State and lifecycle

1. Each piece of state has one owner: a provider. Widgets don't keep their own
   copies of server data.
2. Session state changes only through `AuthController`.
3. Sign-out removes everything user-specific from the device
   ([docs/STORAGE.md §4](docs/STORAGE.md)).

### Generated code and migrations

1. Never hand-edit `*.g.dart`, `*.freezed.dart` or `lib/l10n/generated/`.
   Regenerate with `tool/codegen.sh` and commit the result.
2. Changing a local database schema needs a version bump, a migration and a
   migration test ([docs/STORAGE.md §5](docs/STORAGE.md)).
3. Dependency major-version bumps go in their own `chore(deps)` PR, never
   inside a feature PR.

### Agents and git

1. **An AI agent never commits unless the user explicitly asks for it in
   the current conversation.** Finishing a task, a green gate or an earlier
   "commit that" are not permission for the next commit. Leave changes
   uncommitted, show what changed and a proposed message, and wait.
2. The same holds for `git commit --amend`, rebase, reset, branch creation
   or deletion, merge, tag and push: each needs the user's explicit go-ahead.
3. Agents never merge PRs or push to `main`, and never bypass hooks
   (`--no-verify`).

### Store and release

1. Application id, bundle id, signing configuration and declared permissions
   are permanent on the stores. Changing them needs explicit sign-off in review.
2. Version numbers change only in release PRs ([docs/RELEASING.md §1](docs/RELEASING.md)).

---

## Conventions

### Code

- `dart format` (default width) and `very_good_analysis` with infos treated
  as errors. Zero analyzer output is the only passing state.
- An `// ignore:` needs a comment explaining why, on the line above.
- All user-facing text comes from `lib/l10n/app_en.arb` via `context.l10n`.
- Business rules go in `domain/` as pure functions with unit tests; widgets
  stay thin.
- Model alternatives as `sealed` classes and `switch` exhaustively. A missing
  case is a compile error by config.
- Riverpod without code generation ([ADR 0002](docs/adr/0002-riverpod-without-codegen.md)).
  Names: `thingProvider`; `ThingController extends Notifier<ThingState>`.
- Package imports only (`package:nalum_app/...`), snake_case file names,
  one public widget per file unless the widgets are tiny and related.

### Comments

- Explain **why**: the rationale, the trap avoided, the rule enforced. Cite
  specs as `docs/AUTH.md §3.3`; the gate checks every citation resolves.
- Never write history ("changed from X", "fixed bug"), status ("WIP") or
  commented-out code. That's what git history and PR descriptions are for.
- To-dos need an owner: `TODO(priya): ...`. The gate rejects bare ones.

### Tests

- Pyramid: many pure unit tests (domain, mappers, redirects), a widget test
  per screen state, a few integration flows ([docs/TESTING.md §1](docs/TESTING.md)).
- Every bug fix ships with a test that fails without the fix.
- No network, no real timers, no platform channels in unit/widget tests:
  override providers with the fakes in `test/helpers/`.
- Fixtures are invented and use `example.com` emails ([docs/TESTING.md §6](docs/TESTING.md)).

### Docs

- Docs change in the same PR as the behavior they describe.
- Sections are numbered `## §N Title` / `### §N.M Title` and cited from code.
  **Never renumber.** Add new sections at the end of their level. Retire a
  section by keeping its heading with a "Retired — see …" line.

### Git

Enforced by `tool/check_commit_msg.sh`, both as a local `commit-msg` hook
(`git config core.hooksPath tool/hooks`) and in CI on every PR commit and
PR title:

- **Short.** One subject line of at most **50 characters**:
  `type(scope): summary`, imperative, no trailing period. A body is optional
  and at most 3 lines of ≤ 72 characters, only when the *why* isn't obvious.
- **Types:** `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `ci`,
  `build`, `perf`. Example: `feat(auth): add otp screen`.
- **No co-authors and no AI attribution, ever.** No `Co-authored-by:`,
  `Generated-by:`, `Assisted-by:` or `Signed-off-by:` trailers, no
  "Generated with …" lines, no 🤖. This applies to AI agents too: an agent
  committing here writes a plain conventional message and nothing else. The
  human who opens the PR owns every line.
- One logical change per PR. PRs are squash-merged with the PR title as the
  commit message, so the title follows the same rules ([docs/WORKFLOW.md §6](docs/WORKFLOW.md)).

---

## Verifying changes

Climb only as far as the change needs, but say in the PR which steps you ran.

1. **Unit tests** for what you touched: `flutter test test/<path>_test.dart`.
2. **Fast gate:** `bash tool/check.sh --fast` (format, analyze, boundaries, docs, all tests).
3. **Widget states:** loading, empty, error and data for any screen you touched.
4. **Android emulator** (dev flavor, local backend): light and dark mode, font
   size at 200 %, a small phone, slow network (emulator settings).
5. **iOS:** the CI iOS build, or TestFlight / the shared Mac for anything
   platform-specific (push, sign-in, links) ([docs/WORKFLOW.md §7](docs/WORKFLOW.md)).
6. **Full gate:** `bash tool/check.sh` before pushing.

"Should work" is not verified. If you couldn't run a step, write that in the PR.

---

## Platform / OS quirks

- **Windows:** use Git Bash or WSL for `tool/*.sh`. PowerShell 5.1 has no `&&`.
- **Line endings:** `.gitattributes` forces LF. Also run
  `git config core.autocrlf input` once; CRLF in a `.dart` file fails the format check.
- **Spaces in paths** (e.g. `D:\Projects\Not Mine\...`): always quote paths in
  scripts. The tool scripts are space-safe; keep them that way.
- **Kotlin keyword:** the Android package is ``in.ac.nsut.alumni`` and `in` is a
  Kotlin keyword, so `MainActivity.kt` declares ``package `in`.ac.nsut.alumni``.
  The backticks are correct.
- **Android emulator → host** is `10.0.2.2`. A physical phone uses `adb reverse tcp:2478 tcp:2478`
  and `config/local.json` (gitignored): the backend port is bound to 127.0.0.1, so a LAN IP fails (SETUP.md §3).
- **INTERNET permission** was missing from the Flutter template's main
  manifest (debug worked, release could not connect). It is there now; keep it.
- **iOS** cannot be built on Windows, and iOS flavors are not set up yet
  ([docs/RELEASING.md §2](docs/RELEASING.md)).
- **One lockfile:** this is a pub workspace. `flutter pub get` anywhere resolves
  everything; `pubspec.lock` lives only at the root.
- **l10n output** is `apps/mobile/lib/l10n/generated/`. Flutter's old
  `flutter_gen` synthetic package no longer exists.
- **Codegen versions:** `riverpod_generator` conflicts with
  `freezed`/`json_serializable` on the pinned SDK ([ADR 0002](docs/adr/0002-riverpod-without-codegen.md)).
