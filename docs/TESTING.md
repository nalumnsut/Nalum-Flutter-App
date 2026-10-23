# Testing

Cited as `docs/TESTING.md §N`. All automated tests run in `tool/check.sh`
and in CI.

## §1 The pyramid

| Level | What | Where | Speed |
|---|---|---|---|
| Unit | domain rules, mappers, `authRedirect`, `appLocationForLink`, controllers with fake repositories, interceptors with a fake HTTP adapter | `test/**` mirroring `lib/**`, `packages/*/test` | ms |
| Widget | each screen's loading / empty / error / data states, key interactions | `apps/mobile/test/**` | ~100 ms |
| Golden | `nalum_ui` widgets in light and dark | `packages/nalum_ui/test/goldens/` | ~100 ms |
| Integration | a few end-to-end flows on a device against staging | `apps/mobile/integration_test/` (M5, `patrol`) | minutes |

Most tests are unit tests. A screen gets widget tests for its states; a flow
gets an integration test only if it crosses platform boundaries
(permissions, push, links) or is business-critical (sign-in → verify →
post → message).

## §2 Unit tests

- One behaviour per test, named as a sentence describing it.
- Domain code is pure, so tests are plain `test()` with no setup.
- Controllers: build a `ProviderContainer` with overridden repositories and
  stores (see `auth_controller_test.dart`), `addTearDown(container.dispose)`.
- Network code: inject a fake `HttpClientAdapter`
  (`auth_interceptor_test.dart`). Never hit a real server.

## §3 Widget tests

- Pump `NalumApp` or a screen inside a `ProviderScope` built from
  `appOverrides()` plus fakes, so the wiring under test is production wiring.
- Find by user-visible text or widget type, not by private keys, unless
  text is ambiguous.
- No real timers or `Future.delayed`; use `pumpAndSettle()` or
  `pumpEventQueue()`.

## §4 Golden tests

For `nalum_ui` only (screens change too often). Golden images are generated
on CI's Linux runner because font rendering differs per OS: regenerate with
`flutter test --update-goldens` in CI (a manual workflow) rather than
locally on Windows or macOS.

## §5 Integration tests

Added in M5 with `patrol` (handles native permission dialogs). They run
against **staging** with dedicated test accounts, never production.

## §6 Fixtures and redaction

- Invent people: "Test User", ids like `user-1`, emails `@example.com`.
- When copying a real response shape from the backend, replace every value.
  Keep only the structure.
- No production data, screenshots of real profiles or real tokens in tests,
  issues or PRs.
- Shared fakes live in `apps/mobile/test/helpers/`.

## §7 Manual checks on a device

Run for any UI change before asking for review:

- Light and dark mode.
- Font size at maximum (Android: Settings → Display → Font size; iOS:
  Larger Text) and display size at maximum.
- A small phone (e.g. 360×640 dp emulator) and a large one.
- Slow / no network (emulator network settings): loading and error states
  must show, nothing hangs.
- Screen reader (TalkBack / VoiceOver) on new interactive elements.
- Back gesture / back button behaves as expected in each new route.
