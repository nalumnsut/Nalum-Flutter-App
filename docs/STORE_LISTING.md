# Store listing and policy

Accounts, listing copy, assets, privacy declarations and the policy checklist
for Google Play and the App Store. Cited as `docs/STORE_LISTING.md §N`.

## §1 Accounts and ownership

- Publish under **organization accounts** owned by NSUT or the alumni
  association, never a student's personal account. The listing, signing keys
  and Firebase projects must outlive every batch.
- Both stores need a **D-U-N-S number** for the legal entity. Ask Apple about
  its fee waiver for accredited educational institutions.
- New *personal* Play accounts must run a 14-day closed test with 12+ testers
  before production; organization accounts are exempt.
- Access is granted per person through the console's user management and
  removed at handover ([WORKFLOW.md §10](WORKFLOW.md)).

## §2 App identity

| Field | Value |
|---|---|
| Android application id / iOS bundle id | `in.ac.nsut.alumni` (permanent) |
| Name on device | NALUM |
| Store name | "NALUM: NSUT Alumni" (≤ 30 characters on both stores) — to confirm |
| Play category | Social |
| App Store category | Social Networking (primary), Education (secondary) |
| Devices | Phones. Recommend iPhone-only for v1 (iPad support needs iPad screenshots and layouts); change `TARGETED_DEVICE_FAMILY` to `1` on a Mac if agreed |
| Support email | alumni@nsut.ac.in (to confirm) |
| Privacy policy | Must be a public URL on `alumni.nsut.ac.in` (to be written) |

## §3 Listing copy (draft)

**Play short description (≤ 80):**
Connect with NSUT alumni, students and faculty — chat, events and posts.

**App Store subtitle (≤ 30):** The NSUT alumni network

**Full description (draft):**

> NALUM is the official app of the NSUT Alumni Association.
>
> • Find alumni by batch, branch, company or city, and connect.
> • Message your connections and join batch and city communities.
> • Discover alumni events and host your own.
> • Read and share posts, opportunities and advice.
> • Get notified about connection requests, replies and events.
>
> Alumni verify their NSUT background once; students and faculty sign up
> with their @nsut.ac.in email.

**What's new:** written per release in the release PR ([RELEASING.md §7](RELEASING.md)).

## §4 Assets

| Asset | Google Play | App Store |
|---|---|---|
| Icon | 512×512 PNG | 1024×1024 PNG, no transparency |
| Feature graphic | 1024×500 | — |
| Phone screenshots | 2–8, 16:9 or 9:16 | 6.9-inch set required (e.g. 1320×2868) |
| Tablet screenshots | only if tablets are targeted | 13-inch iPad set if iPad is supported |

Screenshots use the staging backend with invented people
([TESTING.md §6](TESTING.md)). Never real alumni.

## §5 Privacy declarations

This table drives Play's **Data safety** form and Apple's **privacy
labels**. Update it in the same PR as any change to collected data or
permissions ([AGENTS.md](../AGENTS.md) "Hard rules").

| Data | Collected for | Linked to user | Shared with third parties | Notes |
|---|---|---|---|---|
| Name, email | Account, app functionality | Yes | No | |
| User id | App functionality | Yes | No | |
| Profile photo, post images | User content | Yes | No | Stored on our backend/CDN |
| Posts, comments, messages | User content | Yes | No | |
| Education/employment (batch, branch, company, role) | App functionality | Yes | No | |
| Approximate location (city) | App functionality | Yes | No | Use coarse location only; precise coordinates are not needed for a city |
| Device push token | Notifications | Yes | No (FCM is a processor) | M3 |
| Crash logs, diagnostics | App stability | No | No (Crashlytics is a processor) | M3 |

Also declare: data encrypted in transit; users can request deletion (in-app
and web); no tracking; no ads.

## §6 Review access

Both stores need to get past sign-in and the verification gates.

- Create a **reviewer account** on production: verified alumni, completed
  profile, a few connections and conversations with other test accounts, a
  post and an event. Invented details only.
- Keep its credentials in the vault and enter them in Play Console "App
  access" and App Store Connect "Sign-in required".
- Review notes explain: what NALUM is, that alumni verification is manual
  and the reviewer account is pre-verified, where to find chat, reporting
  and blocking, and how to delete the account.

## §7 Content rating

Answer the IARC (Play) and Apple age-rating questionnaires honestly: the app
has user-generated content, user-to-user messaging and user-visible city
location; no violence, gambling or mature themes from us. Expect a teen-level
rating. Revisit if features change.

## §8 Policy checklist

- [ ] Privacy policy and terms URLs live, linked in the app and listings.
- [ ] In-app account deletion ([AUTH.md §7](AUTH.md)) **and** a web deletion
      URL (Play requirement).
- [ ] Sign in with Apple offered on iOS if Google sign-in is (Apple 4.8).
- [ ] User-generated content (Apple 1.2, Play UGC): users accept terms at
      sign-up; report posts, comments, users, messages and events; block
      users; a moderation process that acts on reports within 24 h
      ([API.md §4](API.md) B8).
- [ ] No in-app payments or donations. Contribute links to email or the
      website only (Apple 3.2.1(vi) / 3.2.2).
- [ ] No links that install APKs from outside Play (the website's Resources
      page has one; the app's Resources list comes from `/app-config`
      without it).
- [ ] Permission strings explain the purpose (photos, camera, location,
      notifications). Request each one in context, not at launch.
- [ ] iOS `PrivacyInfo.xcprivacy` declares required-reason APIs; check
      bundled SDKs ship their own manifests.
- [ ] Export compliance: HTTPS only → `ITSAppUsesNonExemptEncryption = NO`.
- [ ] Target the Android API level Play requires this year (it rises every
      August).
- [ ] Not a website wrapper (Apple 4.2): native screens, push, offline chat.
