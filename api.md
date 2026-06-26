# SocialBox — External APIs & OAuth

**Source of truth:** `lib/core/constants/api_endpoints.dart`, `lib/features/social_auth/data/services/oauth_service.dart`  
**Status:** OAuth service implemented; remote posting datasource is **partial / scheduled 2027** (see `features.md`)

---

## Platform Name Mapping (critical)

Three different string systems exist — mixing them causes crashes and bad data.

| Context | Facebook | LinkedIn | Twitter/X |
|---------|----------|----------|-----------|
| `SocialPlatform` enum | `facebook` | `linkedin` | `twitter` |
| DB / logs / junction | `facebook` | `linkedin` | `twitter` |
| UI `displayName` | `Facebook` | `LinkedIn` | `Twitter / X` |
| AI Writer dropdown | `Facebook` | `LinkedIn` | `X` |

**Always use:**
- DB/API layer → `SocialPlatform.name`
- AI Writer → `PromptConfig.aiPlatforms` + `normalizePlatform()` / `platformFromSocial()`
- Never pass `displayName` to AI dropdowns or `DropdownButton` with fixed item list

---

## OAuth Configuration

| Field | Value |
|-------|-------|
| Package / scheme | `com.linkedif.socialbox` |
| Android manifest placeholder | `appAuthRedirectScheme: com.linkedif.socialbox` |
| Twitter redirect | `com.linkedif.socialbox://oauth/twitter` |
| LinkedIn redirect | `com.linkedif.socialbox://oauth/linkedin` |
| Facebook redirect | `com.linkedif.socialbox://oauth/facebook` |

Credentials (client id/secret) are entered in **Settings → Social Accounts** and stored in **FlutterSecureStorage** — see `keys.md`.

---

## Twitter / X API v2

| Item | Value |
|------|-------|
| Auth URL | `https://twitter.com/i/oauth2/authorize` |
| Token URL | `https://api.twitter.com/2/oauth2/token` |
| API base | `https://api.twitter.com/2` |
| Scopes | `tweet.write`, `users.read`, `offline.access` |
| Flow | PKCE via `flutter_appauth` (`OAuthService._authorizeTwitter`) |
| Register app | [Twitter Developer Portal](https://developer.twitter.com/en/portal/dashboard) |

### Endpoints (when posting is wired)

```
GET  /2/users/me          → profile for ConnectedAccount
POST /2/tweets            → { "text": "..." }
```

External URL pattern: `https://twitter.com/i/web/status/{id}`

---

## LinkedIn API

| Item | Value |
|------|-------|
| Auth URL | `https://www.linkedin.com/oauth/v2/authorization` |
| Token URL | `https://www.linkedin.com/oauth/v2/accessToken` |
| API base | `https://api.linkedin.com/v2` |
| Scopes | `w_member_social`, `r_liteprofile` |
| Flow | Authorization code + manual token exchange |
| Register app | [LinkedIn Developers](https://www.linkedin.com/developers/apps) — enable "Share on LinkedIn" |

### Endpoints

```
GET  /v2/me               → user id for URN
POST /v2/ugcPosts         → share (requires X-Restli-Protocol-Version: 2.0.0)
```

Post body uses `author: urn:li:person:{userId}`.

---

## Facebook Graph API

| Item | Value |
|------|-------|
| Auth URL | `https://www.facebook.com/dialog/oauth` |
| Token URL | `https://graph.facebook.com/oauth/access_token` |
| Graph base | `https://graph.facebook.com/v20.0` |
| Scopes | `pages_manage_posts`, `pages_read_engagement` |
| Flow | Authorization code + manual token exchange |
| Register app | [Meta for Developers](https://developers.facebook.com/apps) |
| Note | Page posting requires **page access token** from `/me/accounts` |

### Endpoints

```
GET  /v20.0/me/accounts   → list pages + page tokens
POST /v20.0/{pageId}/feed → { "message": "...", "access_token": "..." }
```

External URL pattern: `https://www.facebook.com/{pageId}/posts/{postId}`

---

## In-App Service Map

```
SocialAccountsPage
  → AuthCubit
    → ConnectPlatform / DisconnectPlatform (use cases)
      → AuthRepositoryImpl
        → SocialAuthDataSource (SecureStorage)
        → OAuthService (flutter_appauth + http token exchange)
          → DeepLinkHandler (redirect callback)
```

**Token model:** `OAuthTokenModel` in `secure_storage_service.dart` — fields: `accessToken`, `refreshToken`, `expiresAt`, `userId`, `username`, `displayName`, `avatarUrl`, `pageId`, `pageToken`.

---

## Posting Flow (planned / partial)

```
PublishViaApi use case
  → PostRepositoryImpl
    → PostRemoteDataSource (stub)
      → Dio + Bearer token per platform
      → ApiEndpoints.twitterPostTweet / linkedinUgcPosts / facebook feed
    → LogRepository → posting_logs row (method: api)
```

**Not yet production-ready:** WorkManager scheduled posting, token auto-refresh before API calls, Dio auth interceptor.

---

## Deep Links

OAuth callbacks arrive as:

```
com.linkedif.socialbox://oauth/{platform}?code=...&state=...
```

Handled by `DeepLinkHandler` — must match redirect URIs registered in each developer portal **exactly**.

---

## Common API/OAuth Errors

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| Redirect URI mismatch | Portal URI ≠ `AppConstants.*Redirect` | Copy exact URI from `keys.md` |
| LinkedIn/Facebook connect fails | Missing client secret or wrong product | Check app products + credentials in secure storage |
| Twitter PKCE fails | Wrong client type in portal | Use OAuth 2.0 user context + PKCE |
| Token stored but post fails | Expired token, no refresh wired | Re-connect; implement `RefreshAccessToken` |
| `ServiceConfiguration` compile error | Old flutter_appauth API | Use `AuthorizationServiceConfiguration` |
| `AppEndpoints` not found | Typo | Class is `ApiEndpoints` |

---

## Related Docs

- `keys.md` — OAuth storage keys and redirect URIs
- `schema.md` — `posting_logs` and platform string format
- `agents.md` — build/run on `I:` drive
- `features.md` — Phase 6 status