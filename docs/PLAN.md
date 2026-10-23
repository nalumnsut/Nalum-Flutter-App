# NALUM mobile app — plan

Scope, decisions, milestones, risks and open questions for the Flutter app
of the NSUT Alumni Association (`alumni.nsut.ac.in`), targeting Google Play
and the App Store. Cited as `docs/PLAN.md §N`.

The first version of this plan also covered the backend changes, repo
layout, architecture, store readiness and workflow. Those now live in their
own specs:

| Topic | Now in |
|---|---|
| Backend changes the app needs | [API.md §4](API.md) |
| Repository layout | [AGENTS.md](../AGENTS.md) "Repository layout", [ARCHITECTURE.md §2](ARCHITECTURE.md) |
| App architecture, packages | [ARCHITECTURE.md](ARCHITECTURE.md) |
| Auth and sessions | [AUTH.md](AUTH.md) |
| Navigation and deep links | [NAVIGATION.md](NAVIGATION.md) |
| Chat, push, storage | [CHAT.md](CHAT.md), [NOTIFICATIONS.md](NOTIFICATIONS.md), [STORAGE.md](STORAGE.md) |
| Design system | [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) |
| Store readiness | [STORE_LISTING.md](STORE_LISTING.md), [RELEASING.md](RELEASING.md) |
| Quality, CI/CD, team process | [TESTING.md](TESTING.md), [RELEASING.md](RELEASING.md), [WORKFLOW.md](WORKFLOW.md) |

## §1 What the website does today

Source: `nalum/frontend/src/pages/dashboard/*`, `nalum/backend/routes/*`,
`nalum/backend/models/*`, surveyed October 2026.

### §1.1 Roles and access gates

| Role | How they sign up | Gate before dashboard | Can post | Can host events |
|---|---|---|---|---|
| `student` | `@nsut.ac.in` email only | Email verified; re-verify every 180 days | No | No |
| `faculty` | `@nsut.ac.in` email only | Email verified; re-verify every 180 days | Yes | Yes |
| `alumni` | Any email | Email verified **and** alumni verification (code, registry match, or admin review) | Yes (verified only) | Yes |
| `admin` | Created by script only | — (goes to web admin panel) | Yes (auto-approved, auto-pinned) | Yes |

Other gates: profile completion (`/profile-form`), bans (temporary or
permanent, with reason), deactivated accounts. App behaviour:
[AUTH.md §5](AUTH.md).

### §1.2 Dashboard feature inventory

| Area | Web route | Capabilities |
|---|---|---|
| **Overview** | `/dashboard` | Welcome banner, role-based quick actions, recent posts, suggested connections, upcoming events |
| **Directory** | `/dashboard/alumni` | Search by name, batch, branch, campus, company, skills; connect with an optional message; "My Connections" tab (accepted / received / sent / blocked) |
| **Profile view** | `/dashboard/alumni/:userId`, `/dashboard/profile` | Bio, batch/branch/campus or department, location, company/role, experience, skills, socials, connection state |
| **Profile edit** | `/dashboard/update-profile`, `/profile-form` | Multi-step form, profile picture upload and crop, location picker with reverse geocoding, skills, experience, socials, delete account |
| **Alumni verification** | `/dashboard/verify-alumni` | Admin code, or registry match → confirm, else admin review queue; pending/rejected status with reason |
| **Messages** | `/dashboard/chat/:id` | 1:1 conversations, communities (join, leave, mute, clear, assign admin, delete), typing, online status, read receipts, delete message, archive/delete conversation, user search, accept connection from chat, block/unblock |
| **Events** | `/dashboard/events/*`, `/dashboard/host-event` | Upcoming approved events with type filter, like, details, host/edit/delete own events (admin approval; hosting can be switched off), "My Events" with status |
| **Posts** | `/dashboard/posts/*` | Feed with tags, search, visibility (everyone/alumni/students), Markdown, ≤ 2 images, ≤ 5 tags, likes, views, similar posts, pinned posts, threaded comments with @mentions, edit/delete, report, "My Posts" with status |
| **Queries** | `/dashboard/queries` | Ask the admins (title ≤ 50, body ≤ 500, ≤ 2 images), see status and answer, delete |
| **Notifications** | `/dashboard/notifications` + bell | List, unread count, mark read, delete, clear; per-type email/push preferences, do-not-disturb, digest |
| **Resources** | `/dashboard/resources` | External links (hard-coded on the web) |
| **Contribute** | Sidebar button / popup | Info dialog and `mailto:alumni@nsut.ac.in`; no payments |
| **Change password** | `/dashboard/change-password` | Local (non-Google) accounts |
| **Global search** | Header modal | People + posts + events |
| **Alumni map** (public) | `/map` | Clustered map of verified alumni by city |

**Out of scope for the app:** the admin panel (17 pages), public marketing
pages (stories, communities, benefits, about), the Duvi assistant widget,
page-visit analytics, and `givings` (the web redirects it away).

### §1.3 Website stack (for reference)

- Backend: Express 5 (JS, TS rewrite planned), MongoDB, Postgres (alumni
  registry only), Redis (cache, rate limits, BullMQ, Socket.IO adapter),
  Socket.IO chat, Web Push (VAPID), Nodemailer, sharp. One VPS with
  docker compose and nginx.
- Frontend: React 18 + Vite + TanStack Query + shadcn/ui + Leaflet; PWA.
- Design: `design.md` ("Academic Prestige": crimson `#990000`, Hanken
  Grotesk, Material 3 token names).

## §2 Decisions at a glance

| Topic | Decision | Why / record |
|---|---|---|
| Framework | Flutter stable pinned with FVM (`.fvmrc`, 3.41.7) | Same SDK for everyone and CI |
| Repo layout | Pub workspace: `apps/mobile`, `packages/nalum_api`, `packages/nalum_ui` | [ADR 0003](adr/0003-pub-workspace.md) |
| Architecture | Feature-first; each feature split into `domain / data / application / presentation`, boundaries enforced by a script | [ARCHITECTURE.md §4](ARCHITECTURE.md) |
| State | Riverpod 3, hand-written providers (no codegen) | [ADR 0002](adr/0002-riverpod-without-codegen.md) |
| Routing | go_router with one pure redirect function | [ADR 0004](adr/0004-single-router-guard.md) |
| HTTP | dio with an auth interceptor (single-flight refresh) | [AUTH.md §3.3](AUTH.md) |
| Models | freezed + json_serializable in `nalum_api`; generated from OpenAPI once it exists | [API.md §1](API.md) |
| Realtime | `socket_io_client` (backend uses Socket.IO 4) | [CHAT.md](CHAT.md) |
| Local data | drift for chat/offline cache; secure storage for the refresh token | [STORAGE.md](STORAGE.md) |
| Push, crashes | Firebase Cloud Messaging + Crashlytics, one project per flavor | [NOTIFICATIONS.md](NOTIFICATIONS.md) |
| Maps | flutter_map + marker clustering with a keyed tile provider | Same model as the web's Leaflet; no Google Maps billing |
| Sign-in | Email + OTP, Google, Sign in with Apple | Apple 4.8 ([AUTH.md §4](AUTH.md)) |
| Min OS | Android `minSdk 24`, Play's required target; iOS 15+ | Floor set by current Firebase and Flutter |
| App id | `in.ac.nsut.alumni` | Reverse domain of `alumni.nsut.ac.in` |

## §3 Milestones

Sizes assume 4–6 part-time student developers with the backend blockers
([API.md §4](API.md)) worked on in parallel. Re-estimate after M0.

| Milestone | Scope | Needs from backend | Status |
|---|---|---|---|
| **M0 — Foundations** (~2 wks) | Workspace, flavors, CI/CD, gate, `nalum_ui` tokens + core widgets, dio + auth interceptor, auth state + router guard, error mapping, l10n, docs | Agreement on the v1 contract (§3 of API.md) | Scaffold done; Firebase projects, store accounts and iOS flavors pending |
| **M1 — Identity** (~3 wks) | Sign-up/sign-in, OTP, forgot/reset password, Google + Apple, onboarding wizard, alumni verification, banned/expired screens, settings (password, sessions, delete account, legal) | B1–B5, B9, B11, B12; P1 | — |
| **M2 — Network & content (read)** (~3 wks) | Home, directory + filters, profile view, connections, feed + detail + likes + comments + report, events list/detail/like, global search, notifications list | B7, B8; P2 | — |
| **M3 — Messaging & push** (~3 wks) | 1:1 chat, communities, typing, receipts, presence, outbox, FCM push with deep-link routing, preferences, Universal/App Links | B6; P3–P5 | — |
| **M4 — Create** (~2 wks) | Post composer, my posts; host/edit events, my events; queries; profile edit + picture; alumni map; resources; contribute | P6–P8, B10 | — |
| **M5 — Hardening & launch** (~2–3 wks) | Accessibility, dark mode, performance, forced update, crash-free ≥ 99.5 %, store assets, privacy forms, reviewer account, TestFlight + Play testing, production | Universal/App Links files on the website | — |

After v1: an admin moderation module, chat attachments, home-screen widgets,
event RSVP/calendar export, tablet layouts.

## §4 Risks

| Risk | Mitigation |
|---|---|
| The backend rewrite slips and blockers aren't ready | Build against repository interfaces and fakes; agree the v1 contract first |
| Shared-session bug logs users out on every device | B1 before any tester build ([AUTH.md §3.2](AUTH.md)) |
| Store rejection (Apple 4.8, 1.2 UGC, 5.1.1 deletion, reviewer stuck at verification) | [STORE_LISTING.md §8](STORE_LISTING.md) checklist and §6 reviewer account |
| Team turnover across batches | Org-owned accounts and keys, ADRs, CODEOWNERS, committed generated code, FVM, [WORKFLOW.md §10](WORKFLOW.md) |
| No local iOS builds on Windows | CI macOS builds from M0; one shared Mac |
| OSM tile policy forbids heavy app use of public tiles | Keyed tile provider or self-hosted tiles, with caching |

## §5 Open questions

1. Who owns the developer accounts (Apple, Google Play, Firebase)? Is there
   a D-U-N-S number for NSUT or the alumni association?
2. Apple sign-in for students/faculty: link `@nsut.ac.in` by OTP afterwards,
   or offer Apple sign-in to alumni only?
3. Backend rewrite timeline and framework: can the B items be in its first
   milestone?
4. Admins in the app: "use the web" screen in v1 (current), or a moderation
   module?
5. Keep `nalum-app` as its own repo (current) or move it into the website
   monorepo as `apps/mobile`?
6. Should public content (stories, campus news, notable alumni) appear in
   the app? It needs a content API.
7. Who designs and approves dark-mode colors?
8. iPhone-only or iPhone + iPad for v1 ([STORE_LISTING.md §2](STORE_LISTING.md))?
