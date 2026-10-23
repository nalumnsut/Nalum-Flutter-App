# 0004 — One pure router guard for all auth navigation

- Status: Accepted
- Date: 2026-10-23
- Deciders: founding maintainers

## Context

A signed-in user can be in one of several states (email unverified, banned,
profile incomplete, alumni unverified, …) and can arrive at any route
through a deep link or a notification tap. When screens navigate after
sign-in themselves, the rules spread across screens and break on cold-start
deep links. The website had exactly this bug: deep links landed on
`/dashboard` because the guard ran before the session was restored.

## Decision

`authRedirect(AuthStatus, Uri)` in `app/router/` is the **only** place that
decides auth-related navigation. It is a pure function, unit-tested for
every state, and go_router re-runs it whenever `AuthStatus` changes. Screens
never navigate after sign-in, sign-out or gate completion; they change state
and the guard moves them. The original target is carried in `from` and
resumed only if it is a safe in-app path.

## Consequences

- Gate order is defined once ([AUTH.md §5](../AUTH.md)) and tested once.
- Adding a gate means adding a `SessionGate` value, which the compiler then
  forces into every `switch`.
- Developers must resist calling `context.go('/home')` after sign-in.

## Alternatives considered

- **Per-route guards:** duplicated conditions and order bugs.
- **Navigating from controllers:** couples state to the router and breaks
  tests.
