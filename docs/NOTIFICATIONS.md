# Notifications

Push (FCM/APNs), the in-app list and preferences. Push arrives in M3, the
list in M2. Cited as `docs/NOTIFICATIONS.md §N`.

## §1 Overview

| Kind | Source | Shown as |
|---|---|---|
| Push | FCM → device (APNs on iOS) | System notification; foreground banner |
| In-app list | `GET /notifications` | Bell badge + `/notifications` screen |
| Realtime | Socket `notification:*` events | Badge updates while the app is open |

Notification types match the backend model: `connection_request`,
`connection_accepted`, `post_like`, `post_comment`, `comment_reply`,
`comment_mention`, `post_mention`, `new_message`, `event_reminder`,
`event_update`, `event_invitation`, `query_response`, `giving_response`,
`verification_status`, `profile_update`, `banned`, `system_announcement`.
Unknown types render with a generic icon; they must not crash.

## §2 Firebase setup

- **One Firebase project per flavor** (dev, staging, prod), owned by the
  institution's Google account, not a student's ([RELEASING.md §6](RELEASING.md)).
- Android: `google-services.json` per flavor under
  `android/app/src/<flavor>/`. iOS: `GoogleService-Info.plist` per
  configuration. These files identify the project and are not secrets; they
  are committed. Restrict their API keys in the Google Cloud console.
- iOS needs an APNs auth key (.p8) uploaded to Firebase, plus the Push
  Notifications and Background Modes (remote notifications) capabilities.
- Crashlytics is set up in the same step; `AppLogger.error` forwards to it.

## §3 Device registration

Backend item [API.md §4](API.md) B6.

1. After the user is signed in **and** has granted permission, get the FCM
   token and `POST /me/devices { token, platform, app_version }`.
2. Re-register on `onTokenRefresh` and on each app start (idempotent).
3. On sign-out, `DELETE /me/devices/:id` (best effort) and delete the local
   FCM token, so the next user on the device gets nothing meant for the
   previous one.

## §4 In-app list

- `GET /notifications` (paginated), `GET /notifications/unread-count`,
  `PATCH /:id/read`, `PATCH /mark-all-read`, `DELETE /:id`, `DELETE /`.
- Tapping an item marks it read and navigates via its route (§5).
- Preferences screen backed by `GET/PUT /notifications/preferences`
  (per-type email and push switches, do-not-disturb hours, email digest).

## §5 Payload and routing

Push payload (data message):

```json
{ "type": "new_message", "entity_type": "message", "entity_id": "…", "route": "/chat/<conversationId>" }
```

- `route` uses the app path scheme ([NAVIGATION.md §1](NAVIGATION.md)) and
  goes through `appLocationForLink()` before `router.go()`.
- Cold start from a notification: the route is held in `from` until the auth
  guard says the user is ready.
- Foreground: show an in-app banner, or nothing if the user is already in
  that conversation.
- iOS badge = unread notification count from the server.

## §6 Permission and channels

- Ask for notification permission **in context**: after the user sends their
  first connection request or message, with a short explanation first. Never
  on first launch.
- Android 13+ needs the runtime `POST_NOTIFICATIONS` permission.
- Android channels: Messages, Connections, Posts & comments, Events,
  Account. Channel ids are permanent once shipped.
