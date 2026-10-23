# On-device storage

What the app keeps on the phone, where, and for how long. Cited as
`docs/STORAGE.md §N`.

## §1 Inventory

| Data | Store | Lifetime | Status |
|---|---|---|---|
| Refresh token | `TokenStore` → flutter_secure_storage | Until sign-out or rejection | ✓ |
| Access token | Memory (`AccessTokenHolder`) | Process | ✓ |
| Chat conversations, recent messages, outbox | drift (SQLite) | Until sign-out | M3 |
| First page of feed, own profile | drift or in-memory providers | Until sign-out | M2 |
| Theme choice, dismissed tips, last tab | shared_preferences | Survives sign-out (not personal) | M2 |
| Images | `cached_network_image` disk cache | OS-managed, cleared on sign-out | M1 |

Anything not in this table is not stored. Adding a row needs a PR that
updates this table and, if the data is personal, [STORE_LISTING.md §5](STORE_LISTING.md).

## §2 Secure storage

Only secrets go here (today: the refresh token). Access goes through the
`TokenStore` interface so tests use `InMemoryTokenStore` and no code touches
the plugin directly.

- iOS Keychain items survive an app uninstall. On first launch after
  install, the app should clear stale secure-storage entries (track a
  "has launched" flag in shared_preferences) so a reinstall starts signed
  out. Add this in M1.
- Never put tokens in shared_preferences, drift, files or logs.

## §3 Cache rules

- The server is the source of truth; cached data is a display optimisation.
  Every cached screen still refreshes from the network when opened.
- Cache only what a signed-in user would see again soon. No bulk directory
  caching: it is other people's personal data.

## §4 Wipe on sign-out

`AuthController._forget()` is the single wipe entry point. It must clear,
as features land:

- [x] access token, refresh token
- [ ] drift database (delete the file, don't just truncate)
- [ ] image cache
- [ ] FCM token and device registration ([NOTIFICATIONS.md §3](NOTIFICATIONS.md))
- [ ] in-memory providers holding user data (invalidate them)

A feature that stores user data adds its cleanup here in the same PR.

## §5 Schema migrations

drift databases carry a `schemaVersion`. Changing a table means:

1. Bump `schemaVersion`.
2. Write the migration step.
3. Export the schema (`drift_dev schema dump`) and add a migration test from
   every previous shipped version.

Because the chat cache is rebuildable from the server, a failed migration
may delete and recreate the database instead of crashing. The outbox is
the exception: unsent messages must survive.
