# SocialBox — Social Media Auto-Posting Guide

User-facing guide for API-based publishing: what works today, what each platform allows, and how to set it up.

**Related technical docs:** [`api.md`](../api.md) · [`keys.md`](../keys.md) · [`features.md`](../features.md)

---

## 1. What SocialBox Can Do Today

SocialBox supports two posting modes:

| Mode | How it works | Requires OAuth? |
|------|----------------|-----------------|
| **Manual** | Copy content, open the platform app/web, mark as posted | No |
| **API (auto)** | App publishes via official APIs; creates a posting log with external URL | Yes |

API posting is **off by default**. Turn it on in **Settings → Enable API posting**.

Supported API targets:

| Platform | What gets posted | Auto-schedule? | Status in app |
|----------|------------------|----------------|---------------|
| **Facebook** | **Facebook Page** only (not personal profile) | Yes | Implemented — connect + pick a Page |
| **LinkedIn** | **Your member profile** feed (`urn:li:person:…`) | Yes | Implemented — needs LinkedIn developer app |
| **Twitter / X** | Tweet as connected account | Yes | Implemented — needs X developer app |

Scheduled auto-post uses **WorkManager** (Android): checks about every **15 minutes** for posts where `scheduledAt` has passed and status is `scheduled`.

---

## 2. Facebook

### Can SocialBox auto-post to a Facebook Page?

**Yes.** This is the supported Facebook model in SocialBox.

Flow:

1. Create a Meta app at [developers.facebook.com](https://developers.facebook.com/apps)
2. Add **Facebook Login**
3. Add redirect URI: `com.linkedif.socialbox://oauth/facebook`
4. Request scopes: `pages_manage_posts`, `pages_read_engagement`
5. In SocialBox: **Settings → Social Accounts** → enter App ID + App Secret → **Connect Facebook**
6. Pick the **Page** you manage (app loads pages via Graph API `/me/accounts`)
7. Enable **Settings → Enable API posting**
8. Create a post, select **Facebook**, set schedule (or use **Publish via API** on post detail)

API call used: `POST /v20.0/{pageId}/feed` with a **page access token**.

**Meta requirements (production):**

- You must be admin/editor of the Page
- App Review and sometimes **Business Verification** for `pages_manage_posts`
- Page token is stored securely after you select a Page

### Can SocialBox auto-post to a personal Facebook profile?

**No — not via API.** Meta removed public API access for posting to personal timelines. There is no supported “proper” way for third-party apps to auto-publish to a personal profile like you would manually.

**Alternatives:**

| Option | Auto? | Notes |
|--------|-------|-------|
| Use a **Facebook Page** | Yes | Official path; SocialBox supports this |
| **Copy + open Facebook** (manual flow) | No | Use post detail actions or paste yourself |
| Share dialog (user taps Post) | No | Could be added later — still requires user confirmation |
| Unofficial automation | — | Violates Meta Terms of Service — do not use |

If you need “my Facebook” presence for a brand or creator account, create or use a **Page** (or Meta Business Suite).

### Why are Facebook Groups not supported?

Groups are **not implemented** because Meta heavily restricts group publishing APIs:

- Extra permissions and strict **App Review**
- User must typically be a **group admin**
- Policies change often; many apps lost group posting access

SocialBox could add Groups in a future release (new scopes, group picker UI, repository methods), but **Pages** cover most scheduler use cases with a stable API.

---

## 3. LinkedIn

### Can SocialBox post to LinkedIn?

**Yes — to your personal LinkedIn feed** (the account you connect), not a Company Page.

Implementation:

- OAuth scopes: `w_member_social`, `r_liteprofile`
- Profile: `GET /v2/me` → user id
- Publish: `POST /v2/ugcPosts` with `author: urn:li:person:{userId}`

### Setup steps

1. Create an app at [linkedin.com/developers](https://www.linkedin.com/developers)
2. Enable **Sign In with LinkedIn** and **Share on LinkedIn**
3. Add redirect: `com.linkedif.socialbox://oauth/linkedin`
4. In SocialBox: **Settings → Social Accounts** → Client ID + Client Secret → **Connect LinkedIn**
5. **Settings → Enable API posting** → ON
6. Create post → select **LinkedIn** → schedule or publish via API

### Is LinkedIn “fully working”?

The **code path is complete** (OAuth, token refresh, publish, logs, notifications). Whether it works on your device depends on:

- Valid LinkedIn developer app credentials
- LinkedIn product approval for your app (Marketing Developer Platform for production)
- Successful OAuth test on a real device

**Not supported today:** posting to a **LinkedIn Company Page** (would need `w_organization_social` and organization URN — future enhancement).

### Scheduled auto-post on LinkedIn?

**Yes.** Same scheduler as Facebook and X:

- Save post with status **scheduled** and a future `scheduledAt`
- When due, background task calls `PublishViaApi` for each selected platform
- Expect ~15-minute granularity, not second-perfect timing

---

## 4. Twitter / X

### Setup

1. Register app at [developer.twitter.com](https://developer.twitter.com/en/portal/dashboard)
2. Enable OAuth 2.0 PKCE; scopes: `tweet.write`, `users.read`, `offline.access`
3. Redirect: `com.linkedif.socialbox://oauth/twitter`
4. Connect in **Social Accounts** (Client ID; PKCE flow)
5. Enable API posting; create/schedule posts with **Twitter / X** selected

Publish: `POST /2/tweets`

Scheduled auto-post: **Yes** (same background pipeline).

---

## 5. End-to-End Checklist (API Auto-Post)

Use this for any platform:

- [ ] Developer app created on the platform
- [ ] Redirect URI `com.linkedif.socialbox://oauth/{platform}` registered
- [ ] Credentials saved in **Settings → Social Accounts**
- [ ] Account **connected** (shows username / not expired)
- [ ] **Facebook only:** Page selected after connect
- [ ] **Settings → Enable API posting** turned **ON**
- [ ] Post created with correct platform(s) selected
- [ ] For schedule: set date/time → post status becomes **scheduled**
- [ ] Check **Posting Log** for `method: api` and external URL on success

### Manual publish (without waiting for schedule)

Open **Post detail** → per-platform **Publish via API** (when connected and API posting enabled).

---

## 6. Scheduler & Background Behavior

| Item | Detail |
|------|--------|
| Engine | `WorkManager` periodic task (~15 min minimum on Android) |
| Query | Posts with `status = scheduled` and `scheduledAt <= now` |
| Per platform | Skips if already posted today for that post+platform |
| Token | `ensureFreshToken` runs before each API call |
| Notifications | Success/failure alerts via `NotificationService` |
| Master switch | `enableApiPosting` in Settings — off = validation error |

**Device notes:**

- Battery optimization (common on Infinix/Transsion devices) may delay background runs
- Phone needs network when the task fires
- Recurring posts that auto-spawn the next occurrence are **not fully wired** yet

---

## 7. Platform Support Matrix

| Target | API auto-post | Scheduled auto-post | In SocialBox |
|--------|---------------|---------------------|--------------|
| Facebook **Page** | Yes | Yes | Implemented |
| Facebook **personal profile** | No (Meta policy) | No | Manual only |
| Facebook **Group** | Restricted by Meta | — | Not implemented |
| LinkedIn **personal profile** | Yes* | Yes* | Implemented |
| LinkedIn **Company Page** | Possible with extra APIs | — | Not implemented |
| Twitter / X | Yes* | Yes* | Implemented |

\*Requires developer app + OAuth connected on device.

---

## 8. Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| “API posting is disabled” | Master toggle off | Settings → Enable API posting |
| “Facebook page not selected” | No page token stored | Reconnect Facebook → pick a Page |
| “LinkedIn user id missing” | Profile fetch failed | Disconnect → reconnect LinkedIn |
| Post stays scheduled past time | Background delayed or API off | Open app, check settings, use manual Publish via API |
| OAuth fails | Wrong redirect URI or credentials | Match `keys.md` / `api.md` exactly |
| Token expired | Refresh failed | Social Accounts → Refresh or reconnect |

Run on device with logs:

```powershell
$env:PUB_CACHE = "I:\.pub-cache"
Set-Location I:\Posts\socialbox
flutter run -d <device_id> --verbose
```

---

## 9. Future Enhancements (Not in App Yet)

- Facebook **Group** posting (Meta app review + group picker)
- LinkedIn **Company Page** posting (`w_organization_social`)
- Personal Facebook **share sheet** (user-confirmed, not true auto-post)
- Finer-grained schedule (exact alarms / server-side scheduler)
- Recurring post auto-create after publish

Track status in [`features.md`](../features.md).

---

*Last updated: 2026-06-26*