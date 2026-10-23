#!/usr/bin/env bash
# Validates one commit message against AGENTS.md "Conventions" → Git.
# Used by the commit-msg hook (tool/hooks/) and by CI for every PR commit and
# the PR title (which becomes the squash commit).
#
# Usage: bash tool/check_commit_msg.sh <message-file>   or   ... | bash tool/check_commit_msg.sh -
set -euo pipefail

# Drop the comment lines git puts in the editor template.
msg="$(grep -v '^#' "${1:--}" || true)"
subject="$(printf '%s\n' "$msg" | head -n 1)"

fail() {
  echo "Commit message rejected: $*" >&2
  echo "  subject: $subject" >&2
  echo "  rules:   AGENTS.md \"Conventions\" → Git" >&2
  exit 1
}

# `git merge main` into a work branch is allowed (docs/WORKFLOW.md §4).
if [[ "$subject" == Merge\ * ]]; then exit 0; fi

pattern='^(feat|fix|refactor|test|docs|chore|ci|build|perf)(\([a-z0-9-]+\))?!?: [^ ].*[^.]$'
[[ "$subject" =~ $pattern ]] ||
  fail "subject must be 'type(scope): summary' with no trailing period"
((${#subject} <= 50)) || fail "subject is ${#subject} characters; the limit is 50"

body="$(printf '%s\n' "$msg" | tail -n +2 | sed '/^[[:space:]]*$/d')"
body_lines=0
if [[ -n "$body" ]]; then body_lines="$(printf '%s\n' "$body" | wc -l | tr -d ' ')"; fi
((body_lines <= 3)) || fail "body has $body_lines lines; use at most 3 short lines, or none"
if [[ -n "$body" ]] && printf '%s\n' "$body" | grep -q '.\{73,\}'; then
  fail "body lines must be at most 72 characters"
fi

# No co-authors and no tool/AI attribution of any kind.
if printf '%s\n' "$msg" | grep -qiE '^[[:space:]]*(co-authored-by|generated-by|assisted-by|signed-off-by)[[:space:]]*:'; then
  fail "no Co-authored-by / Generated-by style trailers"
fi
if printf '%s\n' "$msg" | grep -qiE 'generated (with|by|using)|🤖'; then
  fail "no 'generated with/by' lines"
fi
exit 0
