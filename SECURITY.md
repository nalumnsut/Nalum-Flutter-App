# Security

## Reporting a vulnerability

Use GitHub's **private vulnerability reporting** on this repository
(Security → Report a vulnerability), or tell a maintainer directly. Never
post it in a PR, the team channel or anywhere public, and don't include real
users' data in the report.

Maintainers acknowledge reports within 3 working days. Backend problems are
forwarded to the website repo's maintainers.

## Handling secrets

- Never commit keystores, `key.properties`, service-account JSON, App Store
  Connect keys or `.env` files. They live in GitHub secrets and the
  institution's vault ([docs/RELEASING.md](docs/RELEASING.md) §4–§5).
- If a secret is committed or leaked: tell a maintainer immediately, rotate
  it, then clean history. Deleting the file in a new commit is not enough.
