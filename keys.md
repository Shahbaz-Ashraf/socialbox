# SocialBox — Keys, Secrets & Configuration

**Never commit real client secrets or access tokens to git.**  
This file documents **key names and URIs only** — not production values.

**Source of truth:** `lib/core/constants/app_constants.dart`, `lib/core/services/secure_storage_service.dart`, `lib/features/social_auth/data/datasources/social_auth_datasource.dart`

---

## App Identity

| Key | Value |
|-----|-------|
| Package ID | `com.linkedif.socialbox` |
| App name | `SocialBox` |
| OAuth URL scheme | `com.linkedif.socialbox` |
| Android `applicationId` | `com.linkedif.socialbox` |
| DB filename | `socialbox.db` |
| DB schema version | `2` |

---

## OAuth Redirect URIs (register in each developer portal)

| Platform | Redirect URI |
|----------|--------------|
| Twitter / X | `com.linkedif.socialbox://oauth/twitter` |
| LinkedIn | `com.linkedif.socialbox://oauth/linkedin` |
| Facebook | `com.linkedif.socialbox://oauth/facebook` |

**Android Gradle** (`android/app/build.gradle`):

```groovy
manifestPlaceholders += ['appAuthRedirectScheme': 'com.linkedif.socialbox']
```

---

## FlutterSecureStorage Keys

Prefix: `socialbox_oauth_` (`AppConstants.oauthTokenPrefix`)

### OAuth tokens (JSON per platform)

| Storage key | Content |
|-------------|---------|
| `socialbox_oauth_facebook` | `OAuthTokenModel` JSON |
| `socialbox_oauth_linkedin` | `OAuthTokenModel` JSON |
| `socialbox_oauth_twitter` | `OAuthTokenModel` JSON |

Token JSON fields: `accessToken`, `refreshToken`, `expiresAt`, `userId`, `username`, `displayName`, `avatarUrl`, `pageId`, `pageToken`.

### OAuth app credentials (per platform)

| Storage key | Content |
|-------------|---------|
| `socialbox_oauth_{platform}_cid` | Client ID (string) |
| `socialbox_oauth_{platform}_cs` | Client secret (string, optional for Twitter PKCE) |

`{platform}` = `facebook` | `linkedin` | `twitter` (enum `.name`).

**On disconnect:** token + `_cid` + `_cs` keys are deleted for that platform.

---

## SharedPreferences Keys

| Key constant | String value | Content |
|--------------|--------------|---------|
| `AppConstants.settingsKey` | `socialbox_settings` | JSON `AppSettings` |
| `AppConstants.promptTemplateKey` | `socialbox_prompt_template` | AI post-writing prompt template (string) |
| `AppConstants.promptLastConfigKey` | `socialbox_prompt_last_config` | Last `PromptConfig` JSON |
| `AppConstants.promptPresetsKey` | `socialbox_prompt_presets` | Array of `PromptPreset` JSON |

### `socialbox_settings` JSON shape

```json
{
  "themeMode": "system",
  "defaultPlatforms": ["linkedin", "twitter"],
  "enableNotifications": true,
  "enableApiPosting": false,
  "reminderLeadMinutes": 15,
  "autoRefreshTokens": true
}
```

`defaultPlatforms` uses `SocialPlatform.name` (`facebook`, `linkedin`, `twitter`).

---

## Notification Channel IDs

| Constant | Channel ID | Name |
|----------|------------|------|
| `remindersChannelId` | `reminders_channel` | Post Reminders |
| `postingChannelId` | `posting_channel` | Posting Results |
| `dailySummaryChannelId` | `daily_summary` | Daily Summary |

---

## Content Limits

| Constant | Value |
|----------|-------|
| `maxCommentLength` | 2000 |
| `maxPostContentLength` | 5000 |
| `maxTagsPerItem` | 10 |
| `defaultReminderLeadMinutes` | 15 |

---

## Developer Portal Checklist

### Twitter / X

1. Create project + app at [developer.twitter.com](https://developer.twitter.com/en/portal/dashboard)
2. Enable OAuth 2.0, type: **Web App** or mobile as applicable
3. Add redirect: `com.linkedif.socialbox://oauth/twitter`
4. Scopes: `tweet.write`, `users.read`, `offline.access`
5. Copy **Client ID** (and secret if required) into app Social Accounts UI

### LinkedIn

1. Create app at [linkedin.com/developers](https://www.linkedin.com/developers/apps)
2. Add product: **Share on LinkedIn**
3. Authorized redirect: `com.linkedif.socialbox://oauth/linkedin`
4. Scopes: `w_member_social`, `r_liteprofile`
5. Copy Client ID + Client Secret into app

### Facebook

1. Create app at [developers.facebook.com](https://developers.facebook.com/apps)
2. Add **Facebook Login** product
3. Valid OAuth redirect: `com.linkedif.socialbox://oauth/facebook`
4. Scopes: `pages_manage_posts`, `pages_read_engagement`
5. Business verification may be required for production
6. Copy App ID + App Secret into app

---

## Environment / Build (local dev)

### Cross-drive Pub cache (required on this machine)

Project lives on `I:\`; default Pub cache on `C:\` causes Kotlin incremental compile failures.

```powershell
$env:PUB_CACHE = "I:\.pub-cache"
Set-Location I:\Posts\socialbox
flutter pub get
```

### Gradle

`android/gradle.properties`:

```
kotlin.incremental=false
```

### Android permissions (`AndroidManifest.xml`)

- `INTERNET`
- `POST_NOTIFICATIONS` (Android 13+)
- `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM`
- Optional: `android:EnableImpeller=false` if GPU issues on device

---

## Security Rules

| Do | Don't |
|----|-------|
| Store tokens in FlutterSecureStorage | Store tokens in SharedPreferences |
| Enter API credentials via in-app Settings UI | Hardcode secrets in Dart source |
| Add `.env` with secrets to `.gitignore` if used later | Commit `google-services.json` secrets or OAuth tokens |
| Rotate credentials if leaked | Log full access tokens in debug prints |

---

## Related Docs

- `api.md` — endpoints and OAuth flows
- `schema.md` — SQLite (separate from these keys)
- `agents.md` — session startup and build commands