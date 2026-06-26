# Session Status — SocialBox

**Last updated:** 2026-06-26  
**App state:** Compiles and runs on Android (Infinix X6853). Device testing completed across all main screens.  
**Full inventory:** See `features.md` (82 implemented · 23 partial · 6 pending · 39 scheduled 2027)

### Architecture policy (all sessions)

- **Stack:** Features-First Clean Architecture · **MVVM** · mixed **BLoC or Cubit** — see `CLAUDE.md` §2
- **Expansion only:** When fixing bugs or adding features, **do not remove** screens, routes, use cases, DB fields, or user actions. Wire partial code forward; never shrink the app to compile.
- **Migration targets:** `PostDetailCubit`, settings/AI prompt repositories + use cases, Bloc for auth/reminders/post-list — without dropping existing UI

---

## Project Snapshot

| Key | Value |
|-----|-------|
| Package | `com.linkedif.socialbox` |
| Architecture | Clean Architecture · BLoC/Cubit · Drift · GoRouter · GetIt |
| DB schema | v2 (`hashtag_suggestions` table) |
| Bottom nav | Home · Calendar · Comments · Posts · Settings |
| Docs | `CLAUDE.md`, `features.md`, `schema.md`, `api.md`, `keys.md`, `agents.md`, `quickref.md` |

### Build (Windows, project on `I:`)

```powershell
$env:PUB_CACHE = "I:\.pub-cache"
Set-Location I:\Posts\socialbox
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run -d <device_id>
```

---

## Not Implemented — By Priority

### P1 — High-value gaps (current roadmap)

| Feature | Status | Notes |
|---------|--------|-------|
| Copy post content to clipboard | **Not implemented** | No copy on `PostDetailPage`, post cards, or create/edit form |
| Copy extracted AI post (one tap) | **Not implemented** | Paste sheet shows `SelectableText` only; no copy button on parsed content |
| Copy posting log external URL | **Not implemented** | `LogTile` opens URL; no “copy link” |
| Copy hashtags to clipboard | **Not implemented** | Chips insert into form; no copy action |
| Posting Log in-app navigation | **Partial** | `/logs` route exists; no bottom-nav or settings link |
| Per-post log detail route link | **Partial** | Route exists; not linked from post detail |
| Settings toggles actually applied | **Partial** | `defaultPlatforms`, `enableNotifications`, `reminderLeadMinutes`, `enableApiPosting` saved but not consumed |
| Reminder prefill from create-post | **Partial** | Navigation passes `extra`; `RemindersPage` ignores it |
| Notification tap → deep link | **Not implemented** | `NotificationService` callback not wired in `main.dart` |
| Duplicate post UI | **Partial** | Use case registered; no button in UI |
| Image attachments UI | **Partial** | DB field + picker dep exist; no form UI |
| Pull-to-refresh on post list | **Partial** | `onRefresh` callback empty |
| Category drag-reorder | **Pending** | No reorder UI |
| Swipe-delete undo SnackBar | **Partial** | Confirm dialog only; no undo |
| Update log status (edit pending/failed) | **Pending** | Use case not built |
| Platform log row (status dots) | **Pending** | Widget not built |
| BLoC debug observer | **Pending** | Not registered in `main.dart` |
| Dedicated hashtag management page | **Scheduled 2027** | Strip-only UI today |
| Export CSV to clipboard | **Not implemented** | Settings export uses `Share.share` only |

### P2 — Clipboard polish (implemented core, missing pieces)

**Implemented today**

- `ClipboardService` — copy + haptic + snackbar (DI singleton)
- Comment copy — tile tap, icon, menu, long-press; usage count++
- Global comment search copy + usage count
- AI prompt copy — studio, dashboard card, preview sheet
- Copy + open external AI (ChatGPT, Gemini, Claude, Copilot)
- Paste AI response — read clipboard on open + manual paste button; parse → new/edit post

**Not implemented / cleanup needed**

| Item | Detail |
|------|--------|
| `copy_feedback_snackbar.dart` | Specified in `CLAUDE.md`; never created (logic inlined in `ClipboardService`) |
| `CommentTile.clipboard` param | Passed from parent but unused in widget |
| Search delegate double-copy | Calls `Clipboard.setData` then `ClipboardService().copyText` (bypasses DI) |
| `_copyAndOpen` inconsistency | Raw `Clipboard.setData` + custom snackbar instead of `ClipboardService` |
| Copy after “Mark as posted” | No shortcut to copy content for manual paste on platform |

### P3 — Social Auth + API (Phase 6 — mostly not implemented)

| Feature | Status |
|---------|--------|
| `PostRemoteDataSource` | **Not implemented** — file does not exist |
| Publish via API use case / UI | **Scheduled 2027** |
| Profile fetch after OAuth (Twitter/LinkedIn) | **Partial** — token stored; profile not loaded into UI |
| Facebook page picker | **Not implemented** |
| Auto token refresh before API calls | **Not implemented** (`autoRefreshTokens` setting unused) |
| Dio client + auth interceptor | **Scheduled 2027** — OAuth uses raw `http` |
| OAuth compile issues | **May remain** — verify `oauth_service.dart` against `flutter_appauth` API |

### P4 — Background & automation (Scheduled 2027)

| Feature | Status |
|---------|--------|
| WorkManager in `main.dart` | **Not wired** |
| Scheduled posting executor | **Not implemented** (`PostDao.getPostsDueForPosting` exists) |
| Recurring post auto-create next occurrence | **Not implemented** — data stored only |
| Posting result notifications | **Not called** — service method exists |
| Daily summary notification | **Not used** — channel created only |
| NetworkInfo / connectivity check | **Not implemented** |

### P5 — Polish, testing, platform (Scheduled 2027)

| Feature | Status |
|---------|--------|
| Unit / widget tests | **Not implemented** — `test/` empty |
| Lottie empty states | **Not implemented** |
| Shimmer skeletons (all pages) | **Partial** — calendar only |
| App icon + splash | **Not implemented** |
| Strict zero-warning lints | **Pending** |
| Windows `main_windows.dart` + window manager | **Not implemented** |
| Injectable / Freezed codegen for DI & states | **Not used** — manual wiring |
| Cloud sync, analytics, bulk ops, new platforms | **Scheduled 2027** |
| In-app AI API (direct LLM calls) | **Scheduled 2027** — external copy/paste workflow only |

---

## Partial Features — Quick Reference

Features that **exist in code** but are **incomplete or unwired**:

```
Navigation     → /logs orphaned, notification deep links missing
Settings       → 5 toggles saved, most not read by app logic
Posts          → duplicate, attachments, pull-refresh, default platforms, reminder offer
Posting Log    → global page + per-post route not linked in UI
Reminders      → create-from-post prefill broken
Social Auth    → connect flow partial; no API posting pipeline
Clipboard      → posts/logs/hashtags copy missing; search delegate cleanup
Comments       → swipe delete without undo; no category reorder
Dashboard      → global SearchDelegate not implemented (comment search only)
```

---

## Known Pitfalls (avoid regressions)

| Issue | Safe approach |
|-------|---------------|
| AI Writer platform crash | Use `PromptConfig.normalizePlatform()` — values: `LinkedIn`, `X`, `Facebook` only |
| Cross-drive build fail | Set `$env:PUB_CACHE = "I:\.pub-cache"`; `kotlin.incremental=false` in `gradle.properties` |
| Drift changes | Bump `AppConstants.dbVersion`, add migration, run build_runner |
| Enum in SQLite | Store `SocialPlatform.name` / `PostStatus.name` — never `displayName` |

---

## Recently Fixed (2026-06-26 session)

- Cross-drive Kotlin/Gradle build (`PUB_CACHE` on `I:`)
- Dashboard `StatCard` layout overflow
- AI Prompt Studio dropdown overflow
- AI Writer crash — `Twitter / X` vs dropdown values (`normalizePlatform` + cubit sanitization)
- `app_database.g.dart` generated; schema v2 hashtags migration
- App runs cleanly on device — no Dart crashes or UI overflows in latest log pass

---

## Remaining Tech Debt (non-blocking)

- `OnBackInvokedCallback` not enabled in manifest (Android 13+ back gesture warning)
- Impeller/Vulkan GPU warnings on some devices (`EnableImpeller=false` in manifest may need full rebuild)
- `comment_search_delegate.dart` — double clipboard write + DI bypass
- `oauth_service.dart` — verify against current `flutter_appauth` types if auth build fails
- ~19 analyzer info-level lints (const, async context gaps)

---

## Documentation Map

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Full architecture spec |
| `features.md` | Complete feature inventory + scorecard |
| `quickref.md` | One-page cheat sheet |
| `schema.md` | Drift tables & migrations |
| `api.md` | OAuth & social API endpoints |
| `keys.md` | Storage keys & redirect URIs |
| `agents.md` | Agent workflow & build commands |
| `STATUS.md` | This file — session state + gaps |

---

## Suggested Next Implementation Order

1. Copy post content + copy log URL (clipboard — small, high impact)
2. Wire settings toggles (`defaultPlatforms`, notifications lead time)
3. Link `/logs` from settings or restore nav tab
4. Fix reminder prefill from create-post flow
5. Wire notification tap → `GoRouter` deep link
6. OAuth fixes + `PostRemoteDataSource` stub (Phase 6 foundation)
7. WorkManager + scheduled posting (2027 milestone)

---

*For implemented features and 2027 roadmap detail, see `features.md`.*