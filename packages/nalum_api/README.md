# nalum_api

Pure-Dart contract with the NALUM backend: endpoint paths, the error envelope
and DTOs. No Flutter and no HTTP client — the app owns networking
(`apps/mobile/lib/core/network`).

- Contract and backend backlog: [`docs/API.md`](../../docs/API.md)
- Regenerate models: `bash tool/codegen.sh` from the repo root.
- Generated `*.g.dart` / `*.freezed.dart` files are committed.
