# Releasing

Versions, flavors, signing, CI/CD and the release checklist. Cited as
`docs/RELEASING.md §N`.

## §1 Versioning

- `apps/mobile/pubspec.yaml` `version: X.Y.Z+N`.
  - **X.Y.Z** (what users see): Y for a milestone or feature release, Z for
    fixes, X for a major redesign. Bumped **only in a release PR**.
  - **N** (build number): CI overrides it with the workflow run number on
    every store build, so Android `versionCode` and iOS `CFBundleVersion`
    always increase and never collide. The `+N` in pubspec is for local
    builds only.
- Every store build comes from a tag `vX.Y.Z` on `main` (or on a
  `release/X.Y` branch for hotfixes, §8). Only people with merge access push tags; a tag
  push starts `release.yml`.

## §2 Flavors and environments

| Flavor | Android id | Name on device | Config | Backend |
|---|---|---|---|---|
| dev | `in.ac.nsut.alumni.dev` | NALUM Dev | `config/dev.json` | local docker |
| staging | `in.ac.nsut.alumni.stg` | NALUM Staging | `config/staging.json` | staging (to be provisioned) |
| prod | `in.ac.nsut.alumni` | NALUM | `config/prod.json` | `alumni.nsut.ac.in` |

- Android: product flavors in `android/app/build.gradle.kts`. Always pass
  the matching config: `--flavor dev --dart-define-from-file=config/dev.json`.
- `AppEnv.fromEnvironment()` refuses to start without a config and refuses
  plain HTTP outside dev, so a build can't silently point at the wrong server.
- Non-prod builds show a corner banner with the flavor name.
- **iOS has no flavors yet** (it needs Xcode). Until then iOS uses one
  configuration with bundle id `in.ac.nsut.alumni`, and the config file
  decides the backend. To add flavors on a Mac: duplicate the
  Debug/Release/Profile build configurations per flavor (`Debug-dev`, …),
  create schemes `dev`, `staging`, `prod`, set `PRODUCT_BUNDLE_IDENTIFIER`
  and the display name per configuration, then switch CI to `--flavor`.

## §3 CI/CD pipelines

| Workflow | Trigger | Does |
|---|---|---|
| `ci.yml` → `check` | every PR, pushes to `main` and `release/*` | `bash tool/check.sh` with `CI=true` (enforced lockfile) |
| `ci.yml` → `commit-messages` | PRs | PR title and every commit pass `tool/check_commit_msg.sh` (short, conventional, no co-author/AI lines) |
| `ci.yml` → `android-apk` | after `check` | Dev-flavor debug APK uploaded as an artifact (7 days) so reviewers can install the PR |
| `ci.yml` → `ios-build` | pushes to `main`, PRs labelled `ios` | `flutter build ios --no-codesign` on macOS (catches iOS compile breaks; macOS minutes are costly, so not on every PR) |
| `release.yml` | tag `v*` pushed by someone with merge access, on `main` or `release/*` | Gate → Android AAB (prod, obfuscated) → Play internal track; iOS IPA → TestFlight when enabled |

Merging into `main` never uploads anything; only a tag does.

The Flutter version comes from `.fvmrc` in every job.

## §4 Android signing

- Use **Play App Signing**: Google holds the app signing key; we hold an
  **upload key**. Losing the upload key is recoverable through Play support;
  leaking it is not a disaster either. Both are still treated as secrets.
- Whoever sets up releasing creates the upload keystore once:
  `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
  and stores it with its passwords in the institution's vault.
- GitHub secrets used by `release.yml`:

  | Secret | Value |
  |---|---|
  | `ANDROID_KEYSTORE_BASE64` | `base64 -w0 upload-keystore.jks` |
  | `ANDROID_KEYSTORE_PASSWORD` | keystore password |
  | `ANDROID_KEY_ALIAS` | `upload` |
  | `ANDROID_KEY_PASSWORD` | key password |
  | `PLAY_SERVICE_ACCOUNT_JSON` | Play Console service account with release permission |

- The workflow writes `android/key.properties` and the keystore at build
  time. Both are gitignored. Without them, release builds use the debug key
  (fine locally, rejected by Play).

## §5 iOS signing

Needs the organization's Apple Developer account ([STORE_LISTING.md §1](STORE_LISTING.md)).

- Register bundle id `in.ac.nsut.alumni`; create the app in App Store Connect.
- Create an App Store Connect API key (App Manager role), an Apple
  Distribution certificate (.p12) and an App Store provisioning profile.
- GitHub secrets: `APPSTORE_ISSUER_ID`, `APPSTORE_KEY_ID`,
  `APPSTORE_PRIVATE_KEY` (.p8 contents), `IOS_DIST_CERT_P12_BASE64`,
  `IOS_DIST_CERT_PASSWORD`, `APPLE_TEAM_ID`.
- Set the repository **variable** `IOS_RELEASE_ENABLED=true` to turn on the
  iOS release job. Until then it is skipped.
- Capabilities to add when their features land: Push Notifications +
  Background Modes (M3), Associated Domains (M3), Sign in with Apple (M1).

## §6 Firebase and crash reporting

- One Firebase project per flavor, created under the institution's Google
  account. Collaborators who release are members; no personal project owns
  production.
- Config files (`google-services.json`, `GoogleService-Info.plist`) are
  committed; they aren't secrets. Restrict the API keys by app id in Google
  Cloud.
- Release builds are obfuscated (`--obfuscate --split-debug-info`). Upload
  the symbol files from `build/symbols` to Crashlytics in the release job so
  stack traces are readable.

## §7 Release checklist

1. [ ] Milestone PRs merged or moved to the next milestone; `main` green.
2. [ ] Release PR into `main`: `chore(release): vX.Y.Z` bumping `version`
      and updating the store "what's new" text in [STORE_LISTING.md §3](STORE_LISTING.md).
3. [ ] Smoke test a staging build of that commit on Android and iOS (sign-in,
      a gate, each tab, push tap once available).
4. [ ] After the release PR merges, tag the merge commit:
      `git checkout main && git pull && git tag -a vX.Y.Z -m "vX.Y.Z" && git push origin vX.Y.Z`.
5. [ ] `release.yml` runs the gate and uploads to the Play internal track and
      TestFlight.
6. [ ] Internal testers check the store builds.
7. [ ] Promote (§9). Watch Crashlytics crash-free users ≥ 99.5 % before each step.
8. [ ] Create a GitHub Release from the tag with the "what's new" notes.

## §8 Hotfixes

For crashes, security or data issues in a released version only; everything
else waits for the next release.

- **`main` has nothing unreleased since the tag:** fix on a normal branch,
  PR into `main`, then a release PR with a Z bump and tag as in §7.
- **`main` already has unreleased work:** create `release/X.Y` from the
  released tag (`git checkout -b release/X.Y vX.Y.Z && git push -u origin release/X.Y`),
  PR the fix into `release/X.Y` with a Z bump, tag `vX.Y.(Z+1)` on that
  branch, then PR the same fix into `main`. Delete the release branch once
  the next regular release ships.

## §9 Store rollout

- **Google Play:** internal testing → closed testing (alumni volunteers) →
  production with staged rollout 10 % → 50 % → 100 %, at least a day apart.
- **Apple:** TestFlight internal → TestFlight external (needs a short Beta
  App Review) → App Store review → phased release over 7 days.
- Pause the rollout if crash-free users drop or a P0 bug appears.

## §10 Upgrading Flutter

A separate `chore(deps)` PR: update `.fvmrc`, run `fvm use`, raise the
`environment: sdk` constraint in all four pubspecs if needed, `flutter pub
upgrade`, `bash tool/codegen.sh`, `bash tool/check.sh`, and an iOS CI build.
