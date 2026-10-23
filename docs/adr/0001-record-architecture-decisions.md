# 0001 — Record architecture decisions

- Status: Accepted
- Date: 2026-10-23
- Deciders: founding maintainers

## Context

The team changes every year. Decisions made in chat or in someone's head are
lost at handover, and the next batch either repeats old debates or undoes
choices without knowing why they were made.

## Decision

Significant decisions are recorded as short ADRs in `docs/adr/`, reviewed in
a PR like code. AGENTS.md routes contributors here before they make an
architectural change.

## Consequences

- A few minutes of writing per decision.
- Reversing a decision means writing a new ADR, which forces the reasons to
  be stated.

## Alternatives considered

- **Wiki or chat history:** not versioned with the code, not reviewed, and
  lost with account changes.
