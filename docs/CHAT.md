# Chat and realtime

1:1 conversations and communities (batch/location group chats) over
Socket.IO. Built in M3. Cited as `docs/CHAT.md §N`.

## §1 Scope

From the website (`/dashboard/chat`): conversation list with unread counts,
1:1 chats with connections, communities (join, leave, mute, clear history,
assign admin), typing indicators, online status, read receipts, delete a
message, archive/delete a conversation, user search, accept a connection
request from the chat, block/unblock.

## §2 Socket lifecycle

- One socket per signed-in session, created in `core/realtime` and exposed
  as a provider. Auth: `auth: { token: <access token> }` in the handshake,
  as the backend's `chatSocket.js` expects.
- Connected only while the app is in the **foreground**. On background the
  socket closes; FCM delivers new messages ([NOTIFICATIONS.md §5](NOTIFICATIONS.md)).
- On resume, reconnect, or access-token refresh: reconnect with the current
  token, run sync (§5), then rejoin open conversation rooms.
- Sign-out disconnects and drops the provider.

## §3 Events

Names as implemented by the backend today:

| Direction | Event | Use |
|---|---|---|
| client → server | `conversation:join` / `conversation:leave` | Enter/leave a room while the chat is open |
| client → server | `message:send` | Send (`conversationId` or `communityId`, `content` ≤ 5000) |
| client → server | `typing:start` / `typing:stop` | Throttled to one per 3 s while typing |
| client → server | `message:read` | Mark read (with ack callback) |
| client → server | `message:delete` | Delete own message |
| server → client | `message:new`, `message:sent`, `message:error` | Delivery |
| server → client | `message:read`, `message:deleted` | Receipts and deletions |
| server → client | `conversation:update` | List ordering, unread counts |
| server → client | `typing:indicator` | Show "typing…" |
| server → client | `user:online` / `user:offline` | Presence (to be scoped, [API.md §4](API.md) P5) |
| server → client | `notification:removed` | Clear a stale notification |

Socket events never update widgets directly: they write to the local store
(§4) and providers stream from it, so every screen shows the same state.

## §4 Local store and outbox

drift (SQLite) tables: `conversations`, `messages` (last N per conversation),
`outbox`. Sending a message:

1. Insert into `messages` with state `sending` and a client-generated id,
   plus a row in `outbox`.
2. Emit `message:send` with that client id ([API.md §4](API.md) P4 makes the
   server deduplicate on it).
3. On `message:sent` replace the temporary row with the server message.
4. On failure or while offline, leave it in `outbox`; flush in order on
   reconnect. Messages stuck for 24 h become `failed` with a retry action.

The database is wiped on sign-out ([STORAGE.md §4](STORAGE.md)).

## §5 Sync after reconnect

Socket events missed while backgrounded are gone. After reconnecting, call
`GET /chat/sync?since=<last cursor>` ([API.md §4](API.md) P3) and apply new,
edited and deleted messages and read receipts before showing live events.
Until P3 exists, refetch the conversation list and the open conversation's
latest page.

## §6 Safety

- Users can block from the chat header and report a message
  ([STORE_LISTING.md §8](STORE_LISTING.md)).
- Message text never goes into logs, analytics or crash reports.
- Links in messages open via `url_launcher` after `appLocationForLink`
  decides whether they belong in-app.
