# Backend API contract

How the app talks to the NALUM backend, what the contract should look like,
and what the backend must change. Cited as `docs/API.md §N`.

## §1 Principles and process

- The backend (`nalumnsut/nalum`) is the source of truth. The app adapts to
  the contract; it never works around a missing endpoint by scraping other
  responses or guessing.
- Every path and DTO lives in `packages/nalum_api`. Features never build URLs.
- **Requesting a backend change:** raise it with the website team
  through their repo's process, quoting the item id from §4 (e.g. "B3:
  Google sign-in mobile audiences"). Put the same id in the app PR that
  needs it (labelled `backend-needed`), and don't merge app code that needs
  it until it's on the website repo's integration branch (`ctest`).
- Once the backend publishes an OpenAPI spec (§4, C1), DTOs in `nalum_api`
  are generated from it instead of hand-written.

## §2 Environments

| Flavor | API base URL | Socket URL | Config |
|---|---|---|---|
| dev | `http://10.0.2.2:2478/api` (local docker) | `http://10.0.2.2:2478` | `apps/mobile/config/dev.json` |
| staging | `https://staging-alumni.nsut.ac.in/api` (to be provisioned) | same host | `config/staging.json` |
| prod | `https://alumni.nsut.ac.in/api` | `https://alumni.nsut.ac.in` | `config/prod.json` |

nginx proxies `/api/` and `/socket.io/` to the backend on the same host.

## §3 Target contract (v1)

What the app is written against. Where today's backend differs, §5 says how
the app copes.

### §3.1 Success envelope

```json
{ "data": { … }, "meta": { "next_cursor": "…" } }
```

All field names are **snake_case**. Timestamps are ISO-8601 UTC strings.
Ids are opaque strings. Media URLs are absolute.

### §3.2 Errors

```json
{ "error": { "code": "VALIDATION_FAILED", "message": "…", "fields": { "email": "invalid" } } }
```

`code` is machine-readable and stable; `message` is for developers and is
never shown to users. Codes the app knows are in `ApiErrorCode`. HTTP status
still matters: 401 = refresh may help, 403 = it won't.

| Code | Status | Meaning |
|---|---|---|
| `UNAUTHORIZED`, `TOKEN_EXPIRED` | 401 | No/expired access token |
| `INVALID_CREDENTIALS` | 401 | Wrong email or password |
| `EMAIL_NOT_VERIFIED` | 403 | Verify email first |
| `BANNED` | 403 | Account banned (body adds `ban_expires_at`, `ban_reason`) |
| `VERIFICATION_EXPIRED` | 403 | NSUT email needs re-verification |
| `ALUMNI_UNVERIFIED`, `PROFILE_INCOMPLETE` | 403 | Gate not passed |
| `GOOGLE_ACCOUNT` | 400 | Password sign-in on a Google-only account |
| `VALIDATION_FAILED` | 400/422 | See `fields` |
| `RATE_LIMITED` | 429 | Back off; `Retry-After` header |
| `UPGRADE_REQUIRED` | 426 | App version below minimum |

### §3.3 Pagination

Cursor-based for every growing list (feed, comments, notifications,
messages, directory): request `?cursor=<opaque>&limit=<n>`, response
`meta.next_cursor` (null at the end). Offset pagination duplicates or skips
items when new ones arrive during infinite scroll.

### §3.4 Versioning and forced update

- Routes live under `/api/v1`. Breaking changes need `/api/v2` or an
  additive change; installed apps stay old for months.
- Every request sends `X-Client: mobile`, plus (from M5) `X-App-Version` and
  `X-App-Platform`.
- `GET /app-config` returns `min_supported_version` and `latest_version` per
  platform, feature flags, a maintenance flag and the Resources list. Below
  the minimum, the server may answer 426 and the app shows a forced-update
  screen.

## §4 Backend backlog

Ids are stable; reference them in PR descriptions and comments. **B** items block a
store release, **P** items are needed for a good app, **C** items are
clean-up for the rewrite.

### §4.1 Blockers (B)

| Id | Change | Why |
|---|---|---|
| B1 | One session per device (`device_id`, `platform`, `device_name`, `app_version`, `last_used_at`, `push_token`); reuse detection revokes only that session; `GET/DELETE /me/sessions` | `getOrCreate()` shares one session per email: web + app rotation trips reuse detection and `deleteMany({user_id})` logs the user out everywhere |
| B2 | Refresh token in the body for `X-Client: mobile`; 60–90 day sliding expiry instead of 10 years | Apps have no cookie jar ([AUTH.md §3.2](AUTH.md)) |
| B3 | Remove the hard-coded JWT secret fallback in `controllers/jwt.controller.js`; fail at startup | Sockets verify with `process.env.JWT_SECRET` only, so a missing env var silently splits REST and socket secrets |
| B4 | Google `verifyIdToken` accepts web, Android and iOS client IDs | Mobile ID tokens have a different audience |
| B5 | `POST /auth/apple`; Apple token revocation on account deletion | App Store Guideline 4.8 and 5.1.1(v) |
| B6 | FCM push: `POST/DELETE /me/devices`, send via FCM honoring preferences and DND, payload `{type, entity_type, entity_id, route}`; chat push only when no live socket | Only Web Push (VAPID) exists ([NOTIFICATIONS.md §3](NOTIFICATIONS.md)) |
| B7 | Object storage + CDN for uploads; absolute URLs with `width`, `height`, `blurhash`; server-side thumbnails; strip EXIF | Files sit on the VPS disk and come back as relative paths |
| B8 | Reports for users, comments, messages and events; blocking hides content everywhere; `terms_accepted_at` + `terms_version` | Apple 1.2 / Play UGC policy; only post reports exist |
| B9 | v1 envelope and error codes (§3.1, §3.2) | Five different response shapes today (§5.1) |
| B10 | `/api/v1` prefix and `GET /app-config` (§3.4) | Old app versions must keep working or be told to update |
| B11 | Re-enable rate limiting on auth routes | Commented out in `routes/auth/index.js`; OTPs can be brute-forced |
| B12 | OTP-based password reset (or Universal/App Links for the reset link) | Email links open the browser, not the app |

### §4.2 Needed for a good app (P)

| Id | Change |
|---|---|
| P1 | `GET /me`: user, profile summary and capabilities (`can_post`, `can_host_event`, `verification_status`, `profile_completed`, `banned`, …) so role rules stop being duplicated in clients |
| P2 | Cursor pagination (§3.3) for feed, comments, notifications, messages, directory |
| P3 | `GET /chat/sync?since=<cursor>` returning new/edited/deleted messages, read receipts and conversation changes |
| P4 | Client message ids (idempotency) on `message:send` |
| P5 | Presence events only to connections and open conversations (today `socket.broadcast.emit` tells everyone) |
| P6 | Chat attachments upload flow (`Message.attachmentUrl` exists, no upload) |
| P7 | Events search endpoint (the website filters the first 50 client-side) |
| P8 | RESTful event routes: `POST /events`, `PATCH/DELETE /events/:id`, `GET /me/events` |
| P9 | Notification `route` in the shared app/web path scheme ([NAVIGATION.md §3](NAVIGATION.md)) instead of `/dashboard/...` |
| P10 | Server-side image validation: size, type, EXIF stripping |

### §4.3 Clean-up for the rewrite (C)

| Id | Change |
|---|---|
| C1 | Generate an OpenAPI spec from the code (e.g. zod schemas in the TS rewrite); generate web and app clients from it |
| C2 | Finish or delete half-built features: `EducationForm`/`CertificationsForm`/`HonorsForm`/`PublicationsForm` (no model fields), `EventPhotoRequest` (no routes, no `Event.gallery`), `givings` (web UI redirects away) |
| C3 | Document what account deletion removes or anonymises; add a web deletion-request page |
| C4 | Consider one database (Mongo + Postgres for a single registry table is overhead for a student team) |

## §5 Legacy behaviour the app copes with

Remove each workaround when the matching §4 item ships.

### §5.1 Response shapes

| Shape | Example routes | App handling |
|---|---|---|
| `{err: true, code: 401, message}` | sign-in, refresh | `ApiError.tryParse` → `UNKNOWN`, flags `banned` / `verification_expired` → codes |
| `{error: true, message}` | Google auth, `authenticateJWT` | → `UNKNOWN` |
| `{success: false, message}` | alumni, admin | → `UNKNOWN` |
| `{error: false, data}` | sign-in, refresh success | `data` unwrapped like v1 |
| bare objects (`{profiles}`, `{locations}`) | search, alumni map | per-repository parsing |

Routes guarded by `authenticateJWT` answer an expired token with **403**,
not 401, so the interceptor does not refresh there. The app does not
refresh on 403 because banned users also get 403.

### §5.2 Field casing

Auth responses mix `email_verified`/`verified_alumni` with
`profileCompleted`/`hasPassword`. `UserDto` uses explicit `@JsonKey` names
for the camelCase ones.

### §5.3 Endpoint drift on the website

The website calls `GET /profile` and `GET /profile/:id`, which don't exist
(the backend has `/profile/me` and `/profile/user/:userId`). The app uses
the backend's paths. This is why §4 C1 matters.
