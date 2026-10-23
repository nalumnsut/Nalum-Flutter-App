# Authentication and sessions

Sign-in, tokens, gates and account deletion. Cited from code as
`docs/AUTH.md §N`. Backend items referenced here are tracked in
[API.md §4](API.md).

## §1 Overview

| Piece | Where |
|---|---|
| Session state (`AuthStatus`, sealed) | `features/auth/domain/auth_status.dart` |
| Gate rules (`gateFor`) | `features/auth/domain/session_gate.dart` |
| Session lifecycle (`AuthController`) | `features/auth/application/auth_controller.dart` |
| HTTP calls | `features/auth/data/auth_repository.dart` |
| Token attach + refresh | `core/network/auth_interceptor.dart` |
| Refresh-token storage | `core/storage/token_store.dart` |
| Navigation on state change | `app/router/auth_redirect.dart` |

## §2 Endpoints

| Purpose | Path | Status |
|---|---|---|
| Email sign-in | `POST /auth/sign-in` | exists |
| Sign-up | `POST /auth/sign-up` | exists |
| Email OTP send / verify | `POST /auth/send-otp`, `POST /auth/verify-account-otp` | exist |
| Refresh | `POST /auth/refresh` | exists, cookie-only → needs body mode (§3.2) |
| Sign-out | `POST /auth/logout` | exists, cookie-only → needs body mode |
| Google | `POST /auth/google` | exists, web audience only → needs mobile audiences (§4) |
| Apple | `POST /auth/apple` | **missing** (§4) |
| Current user + capabilities | `GET /me` | **missing**; auth responses carry the user meanwhile |
| Change password | `POST /auth/change-password` | exists |
| Forgot / reset password | `POST /auth/forget-password` (link-based) | needs OTP mode for mobile |
| Delete account | `DELETE /auth/account` | exists (§7) |

## §3 Sessions and tokens

### §3.1 Access token

A short-lived JWT (30 min today), held only in memory in
`AccessTokenHolder`. Losing it is harmless: the next request gets a 401 and
the interceptor refreshes. It is never persisted, logged or put in a URL.

### §3.2 Refresh token on mobile

The website keeps the refresh token in an httpOnly cookie. A mobile app has
no browser cookie jar and must keep it in OS secure storage instead.

- Every request sends `X-Client: mobile`.
- For mobile clients the backend must return `refresh_token` in the response
  body of sign-in and refresh, and accept it in the body of refresh and
  logout as `{ "refresh_token": "…" }`.
- The app stores it via `TokenStore` (Keychain on iOS, Keystore-backed
  encrypted storage on Android) under one key.
- **Until the backend supports this**, `AuthTokens.refreshToken` is null, the
  app cannot persist the session, and every cold start lands on sign-in.
  That is the expected behaviour against the legacy backend.

The backend must also keep **one session per device**, not per email. Today
`sessions.getOrCreate()` reuses one session per email, so the web and the
app would rotate the same refresh token and the reuse detection would log
the user out everywhere ([API.md §4](API.md), item B1).

### §3.3 Refresh: one at a time

`AuthInterceptor` handles 401 by asking `SessionRefresher` (the
`AuthController`) for a new access token, then retries the request once.

- **Single flight:** concurrent 401s await the same refresh future. Without
  this, N parallel requests would rotate the refresh token N times; the
  server treats an old token as theft and revokes the session.
- A retried request keeps the token the refresh returned; `onRequest` does
  not overwrite it.
- Requests with `extra: {'skipAuth': true}` never get a token or refresh.
- Auth endpoints use `authDioProvider`, which has no interceptor, so a
  failing refresh can't recurse.
- `AuthController.refreshAccessToken()` signs out only when the server
  rejects the refresh token (401). Network errors fail the request but keep
  the session.

### §3.4 Sign-out and wipe

`AuthController.signOut()` reads the refresh token, wipes local state
first, then tells the server (best effort). Local wipe covers: access token,
refresh token, and, once they exist, the chat database, cached feed, FCM
registration and notification badges ([STORAGE.md §4](STORAGE.md)).

The same wipe runs when a refresh is rejected.

## §4 Sign-in providers

| Provider | Platforms | Notes |
|---|---|---|
| Email + password | both | Password policy matches the backend (`utils/passwordPolicy.js`). |
| Google | both | `google_sign_in` gives an ID token; the backend must accept the Android and iOS client IDs as audiences, not only the web one. |
| Apple | iOS (and Android optional) | Required by App Store Guideline 4.8 when Google sign-in is offered. Apple may hide the email (private relay) and sends the name only on first sign-in. |

Open decision ([PLAN.md §5](PLAN.md)): students and faculty must use an
`@nsut.ac.in` email, which Apple's private relay can't satisfy. Either they
link their NSUT email by OTP after Apple sign-in, or Apple sign-in is offered
to alumni only.

## §5 Gates

After sign-in, `gateFor(user)` decides whether the user may enter the app.
Order matters; the first match wins:

| # | Gate | Condition | Route |
|---|---|---|---|
| 1 | `banned` | `user.banned` | `/banned` |
| 2 | `emailUnverified` | `!emailVerified` | `/verify-email` |
| 3 | `adminWebOnly` | role is admin | `/admin-web` |
| 4 | `verificationExpired` | student/faculty NSUT email not re-verified in 180 days | `/verify-email` |
| 5 | `profileIncomplete` | `!profileCompleted` | `/onboarding/profile` |
| 6 | `alumniUnverified` | alumni and `!verifiedAlumni` | `/verify-alumni` |
| 7 | `ready` | — | requested route, `from`, or `/home` |

Every gate screen offers sign-out. The legacy backend reports bans and
expired verification as 403 errors on sign-in rather than user fields;
`ApiError.tryParse` maps those flags to `BANNED` / `VERIFICATION_EXPIRED`.

## §6 Alumni verification

Mirrors `/dashboard/verify-alumni` on the website. Three paths, all via
`/alumni/*`:

1. **Code:** an admin-issued 10-character code → `POST /alumni/verify-code`.
2. **Registry match:** name, batch, branch (+ roll no.) →
   `POST /alumni/check-manual` returns candidates from the Postgres alumni
   registry → user picks one → `POST /alumni/confirm-match`.
3. **Admin review:** no match → the request joins the admin queue; status
   comes from `GET /alumni/status` (`pending` / `rejected` + reason).

The screen polls status only on open and on pull-to-refresh; approval
arrives as a `verification_status` push once push exists.

## §7 Account deletion

Required in-app by both stores. `DELETE /auth/account` exists. The app:

1. Explains what is deleted, asks the user to type a confirmation.
2. Calls the endpoint, then runs the full wipe (§3.4).
3. For Apple sign-in users, the backend must revoke the Apple token.

Google Play also needs a **web** deletion URL ([STORE_LISTING.md §8](STORE_LISTING.md)).
