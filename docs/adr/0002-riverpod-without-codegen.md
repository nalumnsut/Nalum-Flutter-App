# 0002 — Riverpod without code generation

- Status: Accepted
- Date: 2026-10-23
- Deciders: founding team

## Context

The plan picked Riverpod with `riverpod_generator`. When the workspace was
created on Flutter 3.41.7 / Dart 3.11.5, `riverpod_generator` could not
resolve together with `freezed` and `json_serializable`:

- every `riverpod_generator` compatible with `riverpod_annotation` 4.x needs
  `analyzer` 9.x or 12.x;
- `json_serializable` 6.14 needs `analyzer` ≥ 10, and Flutter pins `meta`
  1.17.0, which rules out the `analyzer` 10.0.2–13.0 range;
- newer releases of both need Dart 3.12.

Code generators sharing one `analyzer` version is a recurring source of
upgrade pain, and the team also needs freezed/json_serializable for the API
contract.

## Decision

Use Riverpod 3 with **hand-written** providers (`Provider`,
`NotifierProvider`, `FutureProvider`, `AsyncNotifierProvider`, with
`.autoDispose` / `.family` where needed). Code generation stays only for
DTOs in `nalum_api`.

## Consequences

- Slightly more boilerplate per provider; no `.g.dart` files in the app for
  state.
- One fewer generator to keep version-compatible on every Flutter upgrade.
- Providers are explicit about lifetime: plain providers live for the app,
  screen-scoped ones must say `.autoDispose` ([ARCHITECTURE.md §7](../ARCHITECTURE.md)).

## Alternatives considered

- **Pin older freezed/json_serializable to fit riverpod_generator:** couples
  the API package to the state library's analyzer needs.
- **Bloc:** more explicit but more boilerplate; Riverpod already handles DI
  and caching in one tool.
- **Revisit** when a Flutter upgrade lets all three generators resolve
  together; that would be a new ADR.
