# Navigation, routes and deep links

Cited as `docs/NAVIGATION.md §N`. Code: `apps/mobile/lib/app/router/` and
`app/shell/`.

## §1 Route table

App paths mirror the website's URLs so one link scheme serves the web,
Universal Links (iOS), App Links (Android) and push payloads.

| App route | Screen | Website path | Built |
|---|---|---|---|
| `/splash` | Session check / retry | — | ✓ |
| `/login`, `/signup`, `/forgot-password` | Auth | `/login`, `/signup`, `/forgot-password` | login ✓ |
| `/verify-email`, `/banned`, `/admin-web` | Gates | `/otp-verification` | placeholder |
| `/onboarding/profile` | Profile wizard | `/profile-form` | placeholder |
| `/verify-alumni` | Alumni verification | `/dashboard/verify-alumni` | placeholder |
| `/home` (tab) | Overview | `/dashboard` | placeholder |
| `/directory` (tab), `/directory/:userId` | Directory, profile | `/dashboard/alumni`, `/dashboard/alumni/:userId` | placeholder |
| `/connections` | My connections | `/dashboard/alumni?tab=my` | M2 |
| `/posts` (tab), `/posts/:postId`, `/posts/new`, `/posts/:id/edit` | Posts | `/dashboard/posts/...` | placeholder |
| `/events` (tab), `/events/:eventId`, `/events/new`, `/events/:id/edit` | Events | `/dashboard/events/...`, `/dashboard/host-event` | placeholder |
| `/chat` (tab), `/chat/:conversationId` | Messages | `/dashboard/chat/:id` | placeholder |
| `/notifications` | Notifications | `/dashboard/notifications` | placeholder |
| `/settings`, `/settings/password` | Settings | `/dashboard/change-password` | sign-out only |
| `/profile`, `/profile/edit` | Own profile | `/dashboard/profile`, `/dashboard/update-profile` | M2/M4 |
| `/queries`, `/resources`, `/map` | Queries, resources, alumni map | `/dashboard/queries`, `/dashboard/resources`, `/map` | M4 |

Rules:

- Path constants live in `AppRoutes`. Never type a path string in a screen.
- Detail routes are registered **outside** the tab shell so they cover the
  bottom bar.
- Unknown paths render the not-found placeholder via `errorBuilder`.

## §2 The guard

`authRedirect(status, uri)` is the only redirect in the router. It is pure
and fully unit-tested.

| State | Behaviour |
|---|---|
| `AuthUnknown`, `AuthRestoreFailed` | Everything goes to `/splash?from=<target>` |
| `AuthSignedOut` | Public routes allowed; anything else → `/login?from=<target>` |
| `AuthSignedIn`, gate not ready | Forced to the gate route ([AUTH.md §5](AUTH.md)) |
| `AuthSignedIn`, ready | Leaving splash/auth/gate routes → `from` (if safe) or `/home`; other routes allowed |

`from` is user-controllable through links, so it is resumed only if it is a
relative in-app path that isn't an auth or gate route.

The router re-evaluates on every `AuthStatus` change through a
`ValueNotifier` bound to `authControllerProvider`. Screens never navigate
after sign-in or sign-out themselves.

## §3 Deep links

### §3.1 Parsing

`appLocationForLink(uri, trustedHosts:)` turns an incoming link into an app
location, or null to leave it to the browser.

- Accepts `https://alumni.nsut.ac.in/...` (and the flavor's web host) and bare
  app paths from push payloads.
- Maps website `/dashboard/...` paths to app routes (table in §1).
- Rejects other hosts and schemes, and any path segment outside
  `[A-Za-z0-9_-]{1,64}`. Links are untrusted input.

### §3.2 Platform setup (M3)

- **Android App Links:** intent filter with `autoVerify="true"` for
  `alumni.nsut.ac.in`, plus `/.well-known/assetlinks.json` on the website
  with the Play App Signing SHA-256 fingerprint.
- **iOS Universal Links:** Associated Domains entitlement
  `applinks:alumni.nsut.ac.in`, plus `/.well-known/apple-app-site-association`
  on the website.
- Both files are served by the website's nginx; request them in the website
  repo when M3 starts.
- `app_links` delivers the initial and subsequent links to a provider in
  `core/`, which calls `appLocationForLink` and then `router.go`.

## §4 Tabs and the account area

Five tabs in a `StatefulShellRoute.indexedStack`: **Home · Network · Posts ·
Events · Messages**. Each tab keeps its own stack; tapping the active tab
returns to its root.

The shell's app bar holds the notifications bell and the account button.
The account area (`/settings` for now) will hold Profile, Queries,
Resources, Contribute, Settings and Sign out.

Contribute opens an info sheet with `mailto:alumni@nsut.ac.in`. There are no
in-app payments ([STORE_LISTING.md §8](STORE_LISTING.md)).
