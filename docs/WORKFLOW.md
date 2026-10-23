# Team workflow

How the team picks up work, branches, reviews and ships. Roles follow the
website repo (maintainers merge, developers branch and open PRs). Branching
does not: the website needs a `ctest` buffer because every push to its
`main` deploys, but app releases are cut by hand with tags, so here `main`
is the only long-lived branch. Cited as `docs/WORKFLOW.md §N`.

## §1 Roles

| Role | Who | Can | Cannot |
|---|---|---|---|
| **Project lead** | Jatin ([@codrjatin](https://github.com/codrjatin)) | Everything a maintainer can, and merge their own PRs without another review | — |
| **Maintainer** | 3rd years (`@nalumnsut/app-maintainers`) | Review, approve and merge into `main`; cut releases; manage secrets, store consoles and Firebase | Merge their own PR without a second maintainer's review |
| **Developer** | 2nd years | Push their own branches, open PRs into `main`, review others' PRs (non-binding) | Push to or merge into `main` |
| **Apprentice** | 1st years | Same as developers, starting with small tasks a maintainer hands out | Same as developers |

Everyone is a repository collaborator. There are no forks and **no GitHub
issues**: work goes straight to pull requests (§3).

Each developer has one **assigned maintainer** who reviews their PRs.
Maintainers own areas through `.github/CODEOWNERS`.

## §2 Branches

```
main ──●──●──●──●──●──●──●──●──●──  always green, protected; every PR squash-merges here
          ↑  ↑     ↑  ↑   tag v0.2.0 (release)     tag v0.3.0
          │  │     │  │        \
          work branches         release/0.2 ──●── tag v0.2.1   (only if a hotfix is needed)
```

- **`main`**: the only long-lived branch. Every PR targets it and it must
  always pass `tool/check.sh`. Merging into `main` ships nothing; a release
  happens only when a maintainer or the project lead pushes a tag ([RELEASING.md §7](RELEASING.md)).
- **Work branches**: `<yourname>/<type>-<short-topic>` (e.g.
  `priya/feat-login-form`), cut from the latest `main`. Delete after merge.
- **Release branches**: `release/X.Y`, created from tag `vX.Y.Z` **only** when
  a released version needs a hotfix and `main` already has unreleased work
  ([RELEASING.md §8](RELEASING.md)). Otherwise they don't exist.
- Unfinished features can merge to `main` behind a flag or an unrouted
  screen; they stay invisible until a release includes them.

Before starting any task:

```bash
git checkout main && git pull origin main
git checkout -b <yourname>/<type>-<topic>
```

## §3 Planning work without issues

Issues are disabled. The PR is the unit of work.

- Maintainers hand out tasks in the team channel, by milestone
  ([PLAN.md §3](PLAN.md)). Want to work on something else? Ask your assigned
  maintainer first.
- **Claim a task by opening a draft PR right away**, even with one commit.
  The open draft PRs are the list of what is in progress; it avoids two
  people building the same thing.
- Bugs found while testing: fix them in a PR, or tell the maintainer in the
  team channel. Don't open an issue.
- PR labels: `area:` (auth, chat, posts, events, directory, notifications,
  design-system, ci), `milestone` (M0–M5), `backend-needed` (waiting on an
  [API.md §4](API.md) item), `ios` (also starts the iOS CI build).
- Blocked on the backend? Mark the draft PR `backend-needed`, name the
  §4 item id in its description, and move on to something else.

## §4 Pull requests

1. Push your branch and open a **draft PR into `main`** early; it runs CI.
2. Title in conventional-commit form (`feat(auth): add OTP screen`). CI checks
   it, because the squash commit takes the PR title.
3. Fill in the template: what and why, verification steps you ran ([AGENTS.md](../AGENTS.md) "Verifying changes"),
   screenshots in light and dark mode for UI changes.
4. Keep it small: aim for under ~400 changed lines excluding generated files.
   Split big features into stacked PRs (domain → data → UI).
5. Mark ready for review only when CI is green.
6. Address review by pushing new commits. Don't force-push during review; it
   hides what changed. If `main` moved, merge `main` into your branch.
7. The maintainer squash-merges. You delete the branch.

## §5 Reviews

Reviewers check, in order:

1. **Hard rules** in [AGENTS.md](../AGENTS.md): privacy, security, boundaries, no secrets.
2. Behaviour: does it do what the PR description says, including loading, empty,
   error and offline states?
3. Tests: does a test fail without the change? Are edge cases covered (long
   text, missing optional fields, other roles)?
4. Docs and l10n updated in the same PR.
5. Readability for the next batch.

Comment prefixes: `blocking:` must change, `nit:` optional, `question:`
needs an answer. Reviews within two working days; if stuck, ping the
assigned maintainer in the team channel.

New commits after approval dismiss the approval (branch protection). This
replaces the website repo's "no sneaky commits" rule with a setting.

## §6 Commits

Full rules: [AGENTS.md](../AGENTS.md) "Conventions" → Git. In short:

- **Short:** one line, at most 50 characters, `type(scope): summary`, no
  trailing period. Optional body of at most 3 lines.
  Good: `fix(chat): keep outbox order`. Bad: `Fixed some bugs in chat and
  also updated the outbox logic.`
- **No co-authors, no AI attribution:** no `Co-authored-by:` or similar
  trailers, no "Generated with …" lines, whatever tool helped. Whoever opens
  the PR owns every line in it.
- **Enforced twice:** locally by the `commit-msg` hook
  (`git config core.hooksPath tool/hooks`, see [SETUP.md](../SETUP.md)), and
  in CI by the `commit-messages` check on every commit and the PR title.
- **Squash merges use the PR title only.** GitHub's default squash message
  pastes every commit plus `Co-authored-by` lines for anyone who pushed to
  the branch; the repository setting in §11 turns that off.

## §7 Definition of done

A task is done when it is merged into `main` and:

- [ ] `bash tool/check.sh` passes locally and CI is green.
- [ ] It was run on an Android device or emulator (dev flavor).
- [ ] iOS: the CI iOS build passed. Anything platform-specific (push, sign-in,
      links, permissions, keyboard) was also checked on an iPhone through
      TestFlight or the shared Mac.
- [ ] Loading, empty, error and offline states exist and were seen.
- [ ] Long strings, missing optional data, all relevant roles, small screens,
      200 % text and dark mode were checked ([TESTING.md §7](TESTING.md)).
- [ ] Docs, ARB strings and the store privacy table are updated if affected.
- [ ] No debug prints, commented-out code or bare to-dos.

## §8 Working with AI coding agents

- Agents read [AGENTS.md](../AGENTS.md) (also loaded via `CLAUDE.md` and
  `.github/copilot-instructions.md`). Keep it accurate; it is the agent's
  whole picture of the project.
- You are responsible for every line an agent writes. Read the full diff and
  run the gate yourself before pushing.
- Never paste secrets, tokens, `.env` contents or real users' data into an AI
  tool.
- Agents must not merge PRs, push to `main`, push tags, change signing or
  store settings, or add SDKs without the same approval a human would need.
- **Agents don't commit on their own.** An agent commits, amends, rebases,
  tags or pushes only when you explicitly tell it to in that conversation
  ([AGENTS.md](../AGENTS.md) "Hard rules" → Agents and git). Review the
  uncommitted diff first, then say "commit".

## §9 Release cadence

Maintainers cut a release at the end of each milestone, or every two weeks
once the app is live, by tagging `main` ([RELEASING.md §7](RELEASING.md)).
Nothing is released automatically on merge.

## §10 Handover between batches

Each year before the 3rd years graduate:

- [ ] New maintainers added to the GitHub team, CODEOWNERS updated.
- [ ] Store consoles, Firebase and the Apple/Google org accounts: access
      granted to new maintainers through the institution's accounts and
      removed for leavers. No personal account owns anything.
- [ ] Secrets rotated if a leaver had access to raw values.
- [ ] ADRs and docs reviewed for anything that only lived in someone's head.
- [ ] Open PRs merged, handed to someone, or closed.

## §11 One-time repository setup (maintainers)

- [ ] Default branch `main`. Protect it: require a PR, 1 approval from code
      owners, required checks **`check`** and **`commit-messages`**, dismiss
      stale approvals on new commits, squash merges only, block force-push
      and deletion.
- [ ] Restrict who can push to and merge into `main` to
      `@nalumnsut/app-maintainers` and `@codrjatin`. Add `@codrjatin` to the
      ruleset's bypass list so the project lead can merge their own PRs.
- [ ] Settings → General → Pull Requests: allow squash merging only, and set
      the squash commit message to **"Pull request title"** (no body, so no
      auto-added `Co-authored-by` lines).
- [ ] Settings → General → Features: turn **Issues** off (§3).
- [ ] Protect `release/*` the same way (they exist only for hotfixes).
- [ ] Restrict who can push `v*` tags to `@nalumnsut/app-maintainers` and
      `@codrjatin` (tag ruleset): a tag push starts a store upload.
- [ ] Create the `@nalumnsut/app-maintainers` team used in CODEOWNERS (or
      update CODEOWNERS to the real team slug).
- [ ] Enable Dependabot alerts and private vulnerability reporting.
- [ ] Add the release secrets and variables listed in
      [RELEASING.md §4](RELEASING.md) and [RELEASING.md §5](RELEASING.md).
- [ ] Create the PR labels listed in §3.
