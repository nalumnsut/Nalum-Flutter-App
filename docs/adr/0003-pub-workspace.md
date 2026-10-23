# 0003 — One pub workspace with the app and two packages

- Status: Accepted
- Date: 2026-10-23
- Deciders: founding maintainers

## Context

The backend contract (paths, DTOs, error envelope) and the design system
change at a different pace from screens, and UI code should not depend on
JSON shapes. Separate packages make that boundary physical. Managing several
packages used to need extra tooling (Melos) and separate lockfiles.

## Decision

Use a Dart **pub workspace** (Dart ≥ 3.6): the root `pubspec.yaml` lists
`apps/mobile`, `packages/nalum_api` and `packages/nalum_ui`; members declare
`resolution: workspace`. One `pubspec.lock` at the root. No Melos; the
shell scripts in `tool/` loop over members.

## Consequences

- `flutter pub get` anywhere resolves everything; versions can't diverge
  between packages.
- `nalum_api` is pure Dart and testable with `dart test`; a future admin app
  or a different client can reuse it.
- A dependency conflict in any member blocks all of them (this is how the
  riverpod_generator conflict in ADR 0002 surfaced).

## Alternatives considered

- **Single package:** simplest, but nothing stops screens from importing
  DTOs, and the design system can't be reused.
- **Melos:** useful for publishing and many packages; unnecessary for three.
- **App inside the website monorepo:** open question ([PLAN.md §5](../PLAN.md)).
