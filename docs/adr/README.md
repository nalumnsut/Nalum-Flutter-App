# Architecture decision records

Short records of decisions that shape the codebase, so the next batch knows
**why** things are the way they are before changing them.

Write an ADR when you add a package that touches user data or native code,
introduce a pattern others must follow, or reverse an earlier ADR. Copy the
template below into `NNNN-short-title.md` with the next number, open it as a
PR, and get a maintainer's approval. Never edit an accepted ADR's decision;
supersede it with a new one.

| # | Decision | Status |
|---|---|---|
| [0001](0001-record-architecture-decisions.md) | Record architecture decisions | Accepted |
| [0002](0002-riverpod-without-codegen.md) | Riverpod without code generation | Accepted |
| [0003](0003-pub-workspace.md) | One pub workspace with app + two packages | Accepted |
| [0004](0004-single-router-guard.md) | One pure router guard for all auth navigation | Accepted |

## Template

```markdown
# NNNN — Title

- Status: Proposed | Accepted | Superseded by NNNN
- Date: YYYY-MM-DD
- Deciders: names / roles

## Context
What forces are at play? What problem are we solving?

## Decision
What we will do, stated plainly.

## Consequences
What gets easier, what gets harder, what we must watch for.

## Alternatives considered
Each option and why it lost.
```
