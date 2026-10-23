# NALUM — NSUT Alumni Association app

The Flutter app (Android + iOS) for [alumni.nsut.ac.in](https://alumni.nsut.ac.in):
directory and connections, posts, events, chat and notifications for NSUT
alumni, students and faculty.

**Start here:** [AGENTS.md](AGENTS.md) is the operating manual (commands,
layout, hard rules, conventions). The specs are in [docs/](docs/README.md).

## Quick start

Prerequisites: Flutter 3.41.7 (see `.fvmrc`; [FVM](https://fvm.app) recommended),
Android Studio or an Android SDK, and Git Bash or WSL on Windows.

```bash
git clone https://github.com/nalumnsut/nalum-app.git
cd nalum-app
git config core.autocrlf input
git config core.hooksPath tool/hooks
flutter pub get
bash tool/check.sh
```

Run against a local backend (website repo: `npm run dev:up`):

```bash
cd apps/mobile
flutter run --flavor dev --dart-define-from-file=config/dev.json
```

## Contributing

Collaborators open pull requests directly; there are no issues. Set up with
[SETUP.md](SETUP.md) (including running on your phone over USB or Wi-Fi),
then read [docs/WORKFLOW.md](docs/WORKFLOW.md) for branches, commits and
reviews.

## Status

M0 (foundations) — see [docs/PLAN.md](docs/PLAN.md) for milestones.
