# Architecture

How the app is put together and why. Sections are cited from code as
`docs/ARCHITECTURE.md §N`; never renumber them.

## §1 Overview

```
┌──────────────────────────── apps/mobile (nalum_app) ────────────────────────────┐
│  app/            composition root: MaterialApp, GoRouter + authRedirect, tab     │
│                  shell, appOverrides()                                           │
│  features/<x>/   presentation → application → data → (nalum_api, core)           │
│                                       └──────→ domain (pure Dart)                │
│  core/           env, dio + AuthInterceptor, TokenStore, AppFailure, logging     │
└──────────────────────────────────────────────────────────────────────────────────┘
          │ uses                                   │ uses
┌─────────▼──────────┐                  ┌──────────▼─────────┐
│ packages/nalum_api │  pure Dart:      │ packages/nalum_ui  │  tokens, ThemeData,
│ paths, DTOs, error │  the backend     │ shared widgets     │  no app logic
│ envelope           │  contract        └────────────────────┘
└─────────┬──────────┘
          │ HTTPS + Socket.IO
┌─────────▼──────────────────────────────────────────┐
│ NALUM backend (nalumnsut/nalum) — owns all data    │
└────────────────────────────────────────────────────┘
```

The app is a **server-authoritative client**: it renders and caches what the
backend says and sends user intent back. Rules that decide what a user may
do are mirrored client-side only to shape the UI, and are replaced by
server-sent capabilities when `/me` exists ([API.md §4](API.md)).

## §2 Repository and packages

A **pub workspace** (root `pubspec.yaml`) with three members and one
`pubspec.lock` ([ADR 0003](adr/0003-pub-workspace.md)):

| Package | Kind | May depend on | Purpose |
|---|---|---|---|
| `apps/mobile` (`nalum_app`) | Flutter app | both packages | Screens, state, networking, platform glue |
| `packages/nalum_api` | Pure Dart | `freezed_annotation`, `json_annotation` | Endpoint paths, DTOs, error envelope ([API.md](API.md)) |
| `packages/nalum_ui` | Flutter package | Flutter only | Tokens, theme, shared widgets ([DESIGN_SYSTEM.md](DESIGN_SYSTEM.md)) |

Why split: the contract and the design system change for different reasons
and at a different pace than screens, and keeping them separate stops UI code
from depending on JSON shapes. A future admin app or widget extension can
reuse both.

## §3 Layers inside the app

| Folder | Contains | Knows about |
|---|---|---|
| `app/` | `NalumApp`, `appRouterProvider`, `authRedirect`, `HomeShell`, `appOverrides()` | Everything. Nothing imports `app/`. |
| `core/` | `AppEnv`, dio providers, `AuthInterceptor`, `TokenStore`, `AppFailure`, `AppLogger`, `failureText` | Packages, Flutter, l10n. Never features. |
| `features/<x>/domain/` | Immutable models, enums, pure rules (`gateFor`, `SessionUser.canPost`) | Dart core, `meta`, other features' domain |
| `features/<x>/data/` | `XRepository` interface + HTTP implementation, DTO → domain mapping | `nalum_api`, `core/`, own domain |
| `features/<x>/application/` | Riverpod providers and `Notifier`s; the feature's public API | Own data and domain, other features' application |
| `features/<x>/presentation/` | Screens and widgets | Own application and domain, `nalum_ui`, `core/ui`, l10n |

Platform hooks (secure storage now; push, deep-link streams, socket later)
live in `core/` behind an interface with a provider, so tests override them
and features never touch platform channels directly.

Feature folders are created when a feature gets real code. Empty layers are
not scaffolded.

## §4 Dependency rules

### §4.1 Why enforce them

Rules that live only in a document erode with every batch of contributors.
`tool/check_architecture.dart` runs in the gate and fails with the rule
number below.

### §4.2 Direction: app → features → core

`core/` must not import `features/` or `app/`; features must not import
`app/`. When core needs feature behaviour it declares an interface and a
provider that throws until overridden; `app/providers.dart` wires the
implementation (example: `SessionRefresher`, implemented by `AuthController`).
Tests use the same `appOverrides()` so wiring can't drift.

### §4.3 Domain is pure Dart

`features/*/domain/**` may import only `dart:async|collection|convert|core|math|typed_data`,
`package:meta`, `package:collection` and other features' `domain/`. No
Flutter, no `dart:io`, no DTOs. Domain code is where the rules live, so it
must run in a plain `dart test` and outlive UI rewrites.

### §4.4 Presentation goes through application

Screens must not import `dio`, `nalum_api` or any `data/` folder. They read
providers from `application/`. This keeps loading/error handling in one
place and makes screens testable with fake providers.

### §4.5 Cross-feature access

A feature may import another feature's `domain/` and `application/` only.
Its `data/` and `presentation/` are private. Shared widgets go to `nalum_ui`;
shared infrastructure goes to `core/`.

### §4.6 Package purity

`nalum_api` must not import Flutter or dio. `nalum_ui` must not import
`nalum_app`, `nalum_api`, dio or Riverpod, and takes already-localized
strings.

## §5 Errors

Every error crossing a repository boundary is an `AppFailure`
(`core/network/app_failure.dart`), a sealed class:

| Failure | From | Typical UI |
|---|---|---|
| `NetworkFailure` | timeouts, no connection | "No connection" + retry |
| `UnauthorizedFailure(code)` | 401 | handled by refresh; sign-in shows "wrong password" |
| `ForbiddenFailure(code)` | 403 | depends on `code` (`BANNED`, …) |
| `ValidationFailure(code, fields)` | 400/422 | inline field errors |
| `NotFoundFailure` | 404 | "not found" state |
| `RateLimitedFailure` | 429 | "wait a minute"; never auto-retry |
| `UpgradeRequiredFailure` | 426 | force-update screen |
| `ServerFailure(status)` | 5xx | generic error + retry |
| `UnexpectedFailure(cause)` | malformed data, bugs | generic error; crash report |

`mapDioException()` builds them using `ApiError.tryParse()` from
`nalum_api`. `failureText()` turns them into localized text. Screens that
need special wording (sign-in treats 401 as wrong credentials) handle that
case first and fall back to `failureText()`.

## §6 Code generation

| Generator | Input | Output | Where |
|---|---|---|---|
| `freezed` + `json_serializable` | `@freezed` DTOs | `*.freezed.dart`, `*.g.dart` | `packages/nalum_api` |
| `flutter gen-l10n` | `lib/l10n/app_en.arb` | `lib/l10n/generated/` | `apps/mobile` |

Generated files are **committed**: anyone can build without running
generators, and reviewers see contract changes in diffs. `tool/check.sh`
regenerates and fails if anything changes, so committed output always
matches its source. `.gitattributes` marks them as generated so GitHub
collapses them in PRs.

## §7 State management

Riverpod 3 with hand-written providers ([ADR 0002](adr/0002-riverpod-without-codegen.md)).

- **Repositories:** `Provider<XRepository>`; overridden with fakes in tests.
- **Server state for a screen:** `FutureProvider` / `AsyncNotifierProvider`;
  screens `switch` on `AsyncValue` (loading / error / data).
- **Long-lived app state:** `NotifierProvider` with a sealed state
  (`AuthController` → `AuthStatus`).
- **Lists:** cursor-paginated `AsyncNotifier` exposing `loadMore()`
  ([API.md §3.3](API.md)).
- Use `ref.watch` in `build`, `ref.read` in callbacks. Never store a `ref`
  in a widget field or a static.
- Hand-written providers live for the whole app unless declared with
  `.autoDispose`. Use `.autoDispose` (and `.family` for ids) for anything
  scoped to a screen, so leaving the screen frees its data.

## §8 Data flows

**Cold start**

```
main → bootstrap → ProviderScope(appOverrides) → NalumApp
  → router at /splash (AuthUnknown)
  → AuthController.build schedules restore()
      TokenStore.read ── none ──→ AuthSignedOut → /login
                     └─ token ─→ POST /auth/refresh
                                   ├ 200 → save rotated token → AuthSignedIn → gate route or /home (or `from`)
                                   ├ 401 → wipe → AuthSignedOut → /login
                                   └ offline → AuthRestoreFailed → splash retry
```

**Authenticated request**

```
screen → provider → repository → apiDio
  → AuthInterceptor adds Bearer token → 200 ✓
                                     → 401 → single shared refresh → retry once
                                                └ refresh rejected → AuthSignedOut → router → /login
```

**Push tap / deep link** (planned M3): payload `route` →
`appLocationForLink()` → `router.go()` → `authRedirect` holds it in `from`
until the user is ready ([NAVIGATION.md §3](NAVIGATION.md)).

## §9 Adding a feature

1. Check [PLAN.md §1](PLAN.md) for scope and the website page it mirrors.
2. Confirm the endpoints exist on the backend's integration branch; add
   paths and DTOs to `nalum_api` and run `bash tool/codegen.sh`.
3. `domain/`: models and rules, with unit tests.
4. `data/`: repository interface + HTTP implementation mapping DTOs to domain
   and `DioException` to `AppFailure`.
5. `application/`: providers; test them with a fake repository.
6. `presentation/`: screens for loading/empty/error/data, strings in the ARB
   file, widget tests.
7. Route it ([NAVIGATION.md §1](NAVIGATION.md)) and map its website URL in
   `appLocationForLink()`.
8. Update the relevant docs and run `bash tool/check.sh`.

## §10 Package policy

Before adding a dependency: is it maintained, does it have a verified
publisher or wide use, does it support both platforms, and does it add
native SDKs that change the privacy answers ([STORE_LISTING.md §5](STORE_LISTING.md))?
New native SDKs or anything touching user data need an ADR.

Planned additions by milestone (from [PLAN.md §2](PLAN.md)):

| Milestone | Packages |
|---|---|
| M1 | `google_sign_in`, `sign_in_with_apple`, `pinput`, `image_picker`, `image_cropper`, `flutter_image_compress`, `cached_network_image` |
| M2 | `infinite_scroll_pagination`, `skeletonizer`, `flutter_markdown_plus`, `url_launcher`, `share_plus` |
| M3 | `socket_io_client`, `drift` + `drift_flutter`, `firebase_core`, `firebase_messaging`, `flutter_local_notifications`, `firebase_crashlytics`, `app_links` |
| M4 | `flutter_map`, `flutter_map_marker_cluster`, `latlong2`, `geolocator` |
| M5 | `upgrader`, `package_info_plus`, `flutter_native_splash`, `flutter_launcher_icons`, `patrol` |

Avoid: GetX, mixing `provider`/`ChangeNotifier` state with Riverpod, the
original `hive`, WebView wrappers of the website.
