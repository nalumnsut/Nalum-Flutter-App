# Docs

Subsystem specs for the NALUM app. Start with [AGENTS.md](../AGENTS.md); its
"Read before working" table routes each kind of task to the right file.

| Doc | Covers |
|---|---|
| [PLAN.md](PLAN.md) | Scope, decisions, milestones, risks, open questions |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Packages, layers, dependency rules, errors, state, data flows |
| [AUTH.md](AUTH.md) | Sign-in, tokens, refresh, gates, verification, deletion |
| [API.md](API.md) | Backend contract, error codes, backend backlog, legacy quirks |
| [NAVIGATION.md](NAVIGATION.md) | Routes, the guard, deep links, tabs |
| [CHAT.md](CHAT.md) | Sockets, events, outbox, sync |
| [NOTIFICATIONS.md](NOTIFICATIONS.md) | Push, in-app list, routing, permissions |
| [STORAGE.md](STORAGE.md) | What is stored on device, wipe, migrations |
| [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) | Tokens, type, components, accessibility |
| [TESTING.md](TESTING.md) | Test levels, fixtures, manual device checks |
| [WORKFLOW.md](WORKFLOW.md) | Roles, branches, PRs, reviews, done, handover |
| [RELEASING.md](RELEASING.md) | Versions, flavors, signing, CI/CD, rollout |
| [STORE_LISTING.md](STORE_LISTING.md) | Accounts, listing, privacy forms, policy checklist |
| [adr/](adr/README.md) | Architecture decision records |

Sections are numbered (`## §3 Title`) and cited from code as
`docs/AUTH.md §3`. Never renumber; `tool/check_docs.dart` verifies every
citation.
