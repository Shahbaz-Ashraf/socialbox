# SocialBox — Feature Inventory

**App:** SocialBox (`com.linkedif.socialbox`)  
**Tagline:** Organize, schedule, and track your social media content  
**Platforms:** Android (primary), Windows (secondary)  
**Architecture:** Features-First Clean Architecture · MVVM · mixed BLoC/Cubit · Drift · GoRouter  
**Last updated:** 2026-06-26

> **Policy:** This inventory only grows. Mark features **Implemented** / **Partial** / **Pending** — do not remove entries when refactoring. Fixes must preserve or extend behavior (`CLAUDE.md` §2 Expansion Policy).

---

## Status Legend

| Status | Meaning |
|--------|---------|
| **Implemented** | Built, wired in UI, and usable end-to-end |
| **Partial** | Core code exists but incomplete, unwired, or missing polish |
| **Pending** | Planned in current roadmap; little or no implementation |
| **Scheduled 2027** | Deferred to a future release cycle (Phase 6+ / polish / platform expansion) |

---

## Navigation & Shell

| Feature | Description | Status | Notes |
|---------|-------------|--------|-------|
| App bootstrap (DI, notifications, portrait lock) | `main.dart` initializes GetIt + local notifications | **Implemented** | WorkManager registered on Android startup |
| Light / dark / system theme | Material 3 theme with persisted `ThemeMode` | **Implemented** | Applied at app root via `SettingsCubit` |
| GoRouter navigation | Shell route + nested routes for all features | **Implemented** | 15+ named routes |
| Bottom navigation (5 tabs) | Home · Calendar · Comments · Posts · Settings | **Implemented** | Posting Log tab removed vs original spec |
| AI Writer route (`/ai-writer`) | Full-screen AI prompt studio | **Implemented** | Reachable from dashboard, posts, settings |
| Posting Log route (`/logs`) | Global posting history page | **Implemented** | Reachable from Settings + Dashboard recent activity |
| 404 error page | Unknown route fallback | **Implemented** | |
| BLoC debug observer | State transition logging | **Implemented** | `AppBlocObserver` in `main.dart` |
| WorkManager background tasks | Scheduled API posting + token refresh | **Implemented** | `BackgroundService` + 15-min periodic task on Android |

---

## Foundation & Core Services

| Feature | Description | Status | Notes |
|---------|-------------|--------|-------|
| Drift SQLite database | 7 tables + 5 DAOs + seed data on create | **Implemented** | Schema v2 (hashtags migration) |
| Dependency injection (GetIt) | Manual `injection_container.dart` | **Implemented** | Injectable annotations present but codegen not used |
| Predefined comment seed data | 8 categories × 5 comments | **Implemented** | Seeded on `onCreate` |
| NotificationService | 3 channels, schedule/cancel, timezone-aware | **Implemented** | Tap → `/posts/:id` in `main.dart` |
| ClipboardService | Copy + haptic + snackbar feedback | **Implemented** | Used in comments + AI writer |
| SecureStorageService | AES-256 OAuth token storage | **Implemented** | |
| Settings persistence | SharedPreferences JSON wrapper | **Implemented** | All toggles consumed by features |
| PromptDataSource | AI template, presets, last config | **Implemented** | SharedPreferences |
| HashtagService | Extract, record, rank hashtag usage | **Implemented** | |
| OAuthService | Twitter PKCE + LinkedIn/FB code exchange | **Partial** | LinkedIn profile fetch + enrichment wired; FB page picker pending |
| DeepLinkHandler | OAuth redirect via `app_links` | **Implemented** | |
| Dio HTTP client + auth interceptor | Centralized API layer | **Implemented** | `DioClient` + `withBearerToken()` for API posts |
| NetworkInfo (connectivity check) | Online/offline detection | **Scheduled 2027** | |
| Background posting executor | Find due posts → publish via API | **Implemented** | `BackgroundService.executeScheduledPosting()` |

---

## 1. Comment Templates

| Feature | Description | Status | Notes |
|---------|-------------|--------|-------|
| Category grid (responsive) | 2-col phone / 3-col tablet | **Implemented** | `CategoriesPage` |
| Category CRUD | Create, edit, delete custom categories | **Implemented** | Predefined categories protected |
| Comments list by category | Search bar + favorites filter | **Implemented** | `CommentsPage` |
| Comment CRUD | Create, edit, delete with tags | **Implemented** | Bottom sheets |
| Copy to clipboard | Tap/copy icon → clipboard + usage count++ | **Implemented** | |
| Toggle favorite | Heart toggle per comment | **Implemented** | |
| Global comment search | `SearchDelegate` across all comments | **Implemented** | From categories app bar |
| Swipe to delete | Dismissible with undo SnackBar | **Implemented** | Restore via `CreateComment` on undo |
| Category drag-reorder | Reorder custom categories | **Implemented** | `SliverReorderableList` — custom categories only |
| Lottie empty states | Animated empty placeholders | **Scheduled 2027** | Polished icon empty states on dashboard tabs |
| Shimmer loading skeletons | Skeleton grid while loading | **Partial** | `DashboardSkeleton` on home; `LoadingListSkeleton` elsewhere |

---

## 2. Posts Manager

| Feature | Description | Status | Notes |
|---------|-------------|--------|-------|
| Post list with status tabs | All · Draft · Scheduled · Posted · Failed | **Implemented** | Stream-based from Drift |
| Create / edit post form | Title, content, platforms, schedule, tags, notes | **Implemented** | `CreateEditPostPage` |
| Platform chip selector | Facebook · LinkedIn · Twitter/X | **Implemented** | |
| Schedule date + time picker | Future `scheduledAt` validation | **Implemented** | |
| Recurring options | none · daily · weekly · custom days | **Implemented** | Stored in DB; no background executor |
| Post detail page | Full content + per-platform actions | **Implemented** | |
| Mark as posted (manual) | Creates log entry + recalculates status | **Implemented** | draft → partial → posted logic |
| Open platform app / web | `url_launcher` deep links | **Implemented** | |
| Delete post | Confirmation dialog | **Implemented** | |
| Post content templates | Canned snippets picker | **Implemented** | `kPostTemplates` |
| Calendar date prefill | `?prefillDate` on create route | **Implemented** | |
| AI response prefill | `AiPostPrefill` → form fields | **Implemented** | |
| Hashtag suggestion strip | Usage-ranked chips in post form | **Implemented** | Records on save |
| Duplicate post | Clone as new draft | **Implemented** | Button on `PostDetailPage` |
| Image attachments | `image_picker` attach files | **Implemented** | Add/remove images in create/edit form |
| Pull-to-refresh on post list | Refresh stream | **Implemented** | `PostListReload` event |
| Default platforms from settings | Pre-select platforms on new post | **Implemented** | `PostFormCubit.applyDefaultPlatforms` |
| Reminder offer after scheduling | Dialog → navigate to reminders | **Implemented** | Router passes prefill; form auto-opens |
| Publish via API | Auto-post to connected platforms | **Implemented** | `PostRemoteDataSource` + `PublishViaApi` (gated by settings toggle) |
| Publish via API button on detail | Per-platform API publish action | **Partial** | UI wired; requires connected account + `enableApiPosting` on |

---

## 3. Posting Log

| Feature | Description | Status | Notes |
|---------|-------------|--------|-------|
| Log data layer (CRUD + streams) | `LogDao`, repository, models | **Implemented** | Auto-created on manual mark-posted |
| Inline logs on post detail | Per-post log section | **Implemented** | `LogCubit` on `PostDetailPage` |
| Dashboard recent activity | Last 8 log entries | **Implemented** | |
| Global posting log page | All logs with platform + status filters | **Implemented** | Linked from Settings |
| Per-post log detail page | All logs grouped for one post | **Implemented** | History button on `PostDetailPage` |
| Log tile (platform, status, method, URL) | Visual log entry row | **Implemented** | External URL for API posts only |
| Update log status | Edit pending / failed / skipped | **Implemented** | `UpdateLogStatus` + `LogTile` menu/bottom sheet |
| Platform log row widget | Compact per-platform status dots | **Implemented** | `PlatformLogRow` on `PostDetailPage` |
| API posting log entries | `method: api` with external URL | **Implemented** | Created by `PublishViaApi` on success |

---

## 4. Reminders

| Feature | Description | Status | Notes |
|---------|-------------|--------|-------|
| Reminder CRUD | Create, edit, delete | **Implemented** | `ReminderFormSheet` |
| Upcoming / past sections | Sorted by `scheduledAt` | **Implemented** | |
| Enable / disable toggle | Schedules or cancels notification | **Implemented** | |
| Repeat types | none · daily · weekly · custom days | **Implemented** | Wired to `NotificationService` |
| Link reminder to post | Optional `postId` foreign key | **Implemented** | Post dropdown in `ReminderFormSheet` |
| Local notification scheduling | `flutter_local_notifications` + timezone | **Implemented** | Payload = `postId` |
| Notification tap → deep link | Navigate to post on tap | **Implemented** | `NotificationService.init(onTap: …)` |
| Settings: enable notifications gate | Master toggle respected by scheduler | **Implemented** | `ReminderBloc` checks `enableNotifications` |
| Settings: reminder lead time | Notify X minutes before post time | **Implemented** | `_notificationAt()` in `ReminderBloc` |
| Auto-suggest reminder on scheduled post | Dialog after saving post | **Implemented** | Prefill + auto-open form via router `extra` |

---

## 5. Social Auth & Connected Accounts

| Feature | Description | Status | Notes |
|---------|-------------|--------|-------|
| Connected accounts page | Connect / disconnect per platform | **Implemented** | `SocialAccountsPage` |
| OAuth token secure storage | Encrypted keystore-backed tokens | **Implemented** | |
| Twitter OAuth 2.0 PKCE | `flutter_appauth` authorization flow | **Partial** | Needs production credentials + device test |
| LinkedIn OAuth 2.0 | Code exchange via HTTP | **Partial** | Profile fetch via `_fetchLinkedInProfile`; needs device credentials test |
| Facebook OAuth 2.0 | Code exchange via HTTP | **Partial** | No page list / page token picker |
| Token refresh | Refresh token exchange | **Implemented** | `AuthRepositoryImpl` + `ensureFreshToken` |
| Profile fetch (username, avatar) | GET /me per platform | **Implemented** | `enrichWithProfile` — LinkedIn + Twitter wired; needs device test |
| Facebook page picker | Select page + store page token | **Scheduled 2027** | |
| Settings: enable API posting toggle | Master switch for auto-posting | **Implemented** | Gated in `PublishViaApi` use case |
| Settings: auto-refresh tokens toggle | Background token refresh | **Implemented** | `AuthRepositoryImpl` on load/connect |

---

## 6. Dashboard

| Feature | Description | Status | Notes |
|---------|-------------|--------|-------|
| Stats aggregation | Cross-repo counts (posts, comments, logs) | **Implemented** | `GetDashboardStats` |
| Stat cards grid (8 metrics) | Total, scheduled, posted, drafts, etc. | **Implemented** | |
| Upcoming posts section | Next 5 scheduled posts | **Implemented** | Tap → post detail |
| Upcoming reminders section | Next 5 enabled reminders | **Implemented** | |
| Recent activity section | Last 8 posting log entries | **Implemented** | |
| Platform mix breakdown | Progress bars per platform | **Implemented** | |
| Quick actions | New Post · Calendar shortcuts | **Implemented** | |
| Auto-refresh every 60s | Periodic stats reload | **Implemented** | Shows loading spinner each cycle |
| AI writer quick card | Inline topic → copy prompt → open AI apps | **Implemented** | `DashboardAiWriterCard` |
| Global search (posts + comments) | Unified `SearchDelegate` | **Implemented** | `GlobalSearchDelegate` on dashboard app bar |
| Shimmer skeleton loading | Home screen placeholder while stats load | **Implemented** | `DashboardSkeleton` |
| Polished empty states | Tab feed empty states with actions | **Implemented** | `DashboardEmptyState` |
| Lottie animations | Animated empty placeholders | **Scheduled 2027** | |

---

## 7. Settings

| Feature | Description | Status | Notes |
|---------|-------------|--------|-------|
| Theme mode picker | System · Light · Dark | **Implemented** | |
| Default platforms selector | Pre-select for new posts | **Implemented** | Consumed in `CreateEditPostPage` |
| Enable notifications toggle | Master notification switch | **Implemented** | `ReminderBloc` respects toggle |
| Reminder lead time slider | 0–60 minutes before post | **Implemented** | Applied in notification scheduling |
| Enable API posting toggle | Gate for auto-posting features | **Implemented** | `PublishViaApi` returns validation error when off |
| Auto-refresh tokens toggle | Background OAuth refresh | **Implemented** | `AuthRepositoryImpl` |
| Connected accounts link | → Social accounts page | **Implemented** | |
| Reminders link | → Reminders page | **Implemented** | |
| AI Post Writer link | → AI prompt studio | **Implemented** | |
| Export comments to CSV | `share_plus` file export | **Implemented** | |
| About / version info | App metadata display | **Implemented** | |
| OAuth client ID fields in settings | Per-platform credential inputs | **Implemented** | LinkedIn + Twitter client ID/secret in Settings |

---

## 8. AI Post Writer *(beyond original spec)*

| Feature | Description | Status | Notes |
|---------|-------------|--------|-------|
| AI Prompt Studio (full page) | Configure + template tabs | **Implemented** | `AiPromptStudioPage` |
| Prompt builder engine | Template variable substitution | **Implemented** | `PromptBuilder` |
| Configuration panel | Topic, keywords, platform, audience, voice, limits | **Implemented** | Dropdowns with sanitization |
| Editable system prompt template | Full markdown prompt editor | **Implemented** | Reset to default supported |
| Save / load presets | Named prompt configurations | **Implemented** | SharedPreferences |
| Copy / share prompt | Clipboard + `share_plus` | **Implemented** | |
| Open external AI services | ChatGPT · Gemini · Claude · Copilot links | **Implemented** | Copy prompt then launch app |
| Paste AI response sheet | Parse structured AI output | **Implemented** | `AiResponseParser` |
| Apply AI response to new post | Navigate with `AiPostPrefill` | **Implemented** | |
| Prefill from existing post | AI button on post detail | **Implemented** | Platform normalization fixed |
| Dashboard quick writer card | Topic + platform → copy prompt inline | **Implemented** | |
| In-app AI API integration | Direct LLM calls inside app | **Scheduled 2027** | Designed for external AI tools |

---

## 9. Hashtag Manager *(beyond original spec)*

| Feature | Description | Status | Notes |
|---------|-------------|--------|-------|
| Hashtag suggestions table | Usage-ranked history in Drift | **Implemented** | Schema v2 migration |
| Record hashtag usage on post save | Increment counts from content | **Implemented** | |
| Suggestion strip in post form | Horizontal chips from history | **Implemented** | Tap to add; long-press to copy |
| Extract hashtags / mentions | Regex parsing utility | **Implemented** | `HashtagService` |
| Dedicated hashtag management page | Browse / edit / delete history | **Scheduled 2027** | Strip-only UI today |

---

## 10. Calendar View *(beyond original spec)*

| Feature | Description | Status | Notes |
|---------|-------------|--------|-------|
| Month / week calendar (`table_calendar`) | Visual schedule overview | **Implemented** | Bottom nav tab |
| Event markers per day | Posts + reminders as dots | **Implemented** | |
| Day detail panel | Lists posts and reminders for selected day | **Implemented** | |
| New post from calendar day | Prefill `scheduledAt` via query param | **Implemented** | |
| Navigate to post / reminder | Tap items in day panel | **Implemented** | |
| Drag-to-reschedule on calendar | Move posts by dragging | **Scheduled 2027** | |

---

## 11. API Auto-Posting *(Phase 6 — Scheduled 2027)*

| Feature | Description | Status | Notes |
|---------|-------------|--------|-------|
| PostRemoteDataSource | Twitter v2 · LinkedIn · Facebook Graph API | **Implemented** | Twitter + LinkedIn + Facebook publish methods |
| PublishViaApi use case | Token → API call → log entry | **Implemented** | Gated by `enableApiPosting`; creates API log entries |
| Dio client + per-platform auth interceptor | Bearer token injection | **Implemented** | `DioClient.withBearerToken()` |
| WorkManager periodic posting | Check due posts every 15 min | **Implemented** | `BackgroundService.register()` in `main.dart` |
| Auto token refresh before API calls | Refresh expired tokens | **Implemented** | `ensureFreshToken` in auth repo |
| Posting result notifications | Success / failure alerts | **Scheduled 2027** | Service method exists; never called |
| Daily posting summary notification | End-of-day digest channel | **Scheduled 2027** | Channel created; unused |
| Scheduled post executor for recurring posts | Auto-create next occurrence | **Scheduled 2027** | Recurring data stored; no executor |

---

## 12. Polish, Testing & Platform *(Scheduled 2027)*

| Feature | Description | Status | Notes |
|---------|-------------|--------|-------|
| Unit + widget tests | BLoC tests, use case tests | **Partial** | 8 test files incl. `PostListBloc`, `ai_app_picker_sheet` |
| Lottie animations | Empty states on all list pages | **Scheduled 2027** | Not in `pubspec.yaml` |
| Shimmer skeletons | Loading placeholders on all pages | **Partial** | Home dashboard skeleton + calendar loading |
| App icon + splash screen | Branded launch experience | **Scheduled 2027** | |
| Strict `analysis_options.yaml` lints | Zero-warning CI target | **Implemented** | `flutter analyze` — 0 issues |
| Windows desktop entry point | `main_windows.dart` + window manager | **Scheduled 2027** | Flutter Windows target exists |
| Cached network images for avatars | OAuth profile pictures | **Scheduled 2027** | Dependency present; avatars never fetched |
| Injectable / Freezed codegen | Replace manual DI + Equatable states | **Scheduled 2027** | Annotations exist; manual wiring used |
| Cloud sync / team accounts | Remote datasource swap (Supabase/Firebase) | **Scheduled 2027** | Extension point in architecture |
| Post analytics dashboard charts | Engagement metrics per platform | **Scheduled 2027** | |
| Bulk post operations | Bulk delete / bulk mark-posted | **Scheduled 2027** | |
| New platforms (Instagram, TikTok, WhatsApp) | Extend `SocialPlatform` enum + OAuth | **Scheduled 2027** | |
| AI comment generation | LLM-generated comments into library | **Scheduled 2027** | |

---

## Summary Scorecard

| Area | Implemented | Partial | Pending | Scheduled 2027 |
|------|:-----------:|:-------:|:-------:|:--------------:|
| Navigation & Shell | 9 | 0 | 0 | 0 |
| Foundation & Services | 11 | 1 | 0 | 2 |
| Comment Templates | 10 | 0 | 0 | 1 |
| Posts Manager | 17 | 1 | 0 | 1 |
| Posting Log | 9 | 0 | 0 | 0 |
| Reminders | 9 | 0 | 0 | 0 |
| Social Auth | 5 | 2 | 0 | 2 |
| Dashboard | 12 | 0 | 0 | 1 |
| Settings | 12 | 0 | 0 | 0 |
| AI Post Writer | 11 | 0 | 0 | 1 |
| Hashtags | 4 | 0 | 0 | 1 |
| Calendar | 5 | 0 | 0 | 1 |
| API Auto-Posting | 5 | 0 | 0 | 3 |
| Polish & Platform | 1 | 2 | 0 | 10 |
| **Totals** | **120** | **6** | **0** | **24** |

---

## 2027 Roadmap (Scheduled Items)

The following are explicitly targeted for the **2027 release cycle**:

1. **API auto-posting** — ✅ Core pipeline shipped; recurring post auto-create still pending
2. **OAuth completion** — ✅ LinkedIn profile fetch + token refresh; Facebook page picker pending
3. **Settings integration** — ✅ All toggles wired (notifications, lead time, default platforms, API posting gate)
4. **Posting log navigation** — ✅ Settings + Dashboard links; optional bottom-nav tab still deferred
5. **Notification deep links** — ✅ Wired (`main.dart` → `/posts/:id`)
6. **Post attachments UI** — ✅ Image picker in create/edit form
7. **Production polish** — Lottie, shimmer, app icon, splash, tests
8. **Windows desktop** — Dedicated entry point and window management
9. **Platform expansion** — Instagram, TikTok, or WhatsApp Business API
10. **Cloud sync** — Optional team / multi-device sync layer

---

## Current App Strengths (2026)

What works well today for daily use:

- **Comment library** — Full CRUD, copy, favorites, search, seeded templates
- **Post queue** — Create, schedule, manual mark-posted, status tracking
- **Calendar** — Visual month view with posts and reminders
- **AI-assisted writing** — Prompt builder → external AI → paste response as post
- **Hashtag memory** — Learns and suggests tags from your posting history
- **Dashboard** — At-a-glance stats, upcoming items, recent activity
- **Offline-first** — Everything works without an account or internet

---

*Generated from codebase audit on 2026-06-26. See `CLAUDE.md` for architecture spec and `STATUS.md` for session notes.*