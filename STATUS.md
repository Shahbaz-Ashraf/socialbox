# Session Status — SocialBox

**Last updated:** 2026-06-26 (session wrap — guides + device QA + health check)  
**App state:** `flutter analyze` — **0 issues** · `flutter test` — **27 passed**. UI polish complete; user guides added under `guide/`.  
**Full inventory:** See `features.md` (core ~100% · 2027 items deferred)  
**Git:** `main` @ `e00ff0d` — synced with `origin/main`

### Architecture policy (all sessions)

- **Stack:** Features-First Clean Architecture · **MVVM** · mixed **BLoC or Cubit** — see `CLAUDE.md` §2
- **Expansion only:** When fixing bugs or adding features, **do not remove** screens, routes, use cases, DB fields, or user actions. Wire partial code forward; never shrink the app to compile.

---

## Implementation Plan — Completed (2026-06-26)

| PR / Area | Status |
|-----------|--------|
| Settings domain layer (`SettingsRepository`, use cases) | **Done** |
| AI prompts domain layer (`PromptRepository`, use cases, sanitizers) | **Done** |
| `PostDetailCubit` + MVVM post detail | **Done** |
| `PostListBloc` + pull-to-refresh | **Done** |
| `ReminderBloc` + notification/lead-time wiring | **Done** |
| `AuthBloc` + auto-refresh tokens | **Done** |
| Domain purity (`AppThemeMode`, `DateRange`, reminder mapper) | **Done** |
| Settings toggles consumed (`enableNotifications`, `reminderLeadMinutes`, `enableApiPosting`, `autoRefreshTokens`, `defaultPlatforms`) | **Done** |
| `HashtagSuggestionsCubit` + long-press copy | **Done** |
| Category drag-reorder | **Done** |
| Swipe-delete undo SnackBar | **Done** |
| `UpdateLogStatus` + `PlatformLogRow` | **Done** |
| Reminder post-picker + prefill from create-post | **Done** |
| Notification deep link (`main.dart` → `/posts/:id`) | **Done** |
| `PublishViaApi` gated stub | **Done** |
| OAuth profile enrichment (Twitter/LinkedIn) | **Done** — LinkedIn `_fetchLinkedInProfile` wired (needs device credentials test) |
| WorkManager + `BackgroundService` | **Done** |
| `PostRemoteDataSource` + `PublishViaApi` | **Done** |
| Global search (`GlobalSearchDelegate`) | **Done** |
| OAuth client ID settings fields | **Done** |
| `/logs` from Settings + Dashboard | **Done** |
| Widget tests (`dashboard_stats_row`, `log_tile`) | **Done** |
| UI polish (home skeleton, settings/posts/calendar cards) | **Done** |
| `PostListBloc` constructor stream subscription fix | **Done** |
| Scrollable bottom sheets (`scrollable_bottom_sheet.dart`) | **Done** |
| Tests: `ai_app_picker_sheet` 320px, `post_list_bloc` | **Done** |
| All bottom sheets → `scrollable_bottom_sheet` | **Done** |
| Posts list/detail, comments, reminders, AI studio polish | **Done** |
| Floating bottom nav (`main_shell.dart`) | **Done** |
| Device screenshots (`screenshots/10–15_*.png`) | **Done** |
| `AppBlocObserver` | **Done** |
| User guides (`guide/social-media-auto-posting.md`) | **Done** — API posting per platform, setup, limitations |
| User guides (`guide/ai-prompt-writer.md`) | **Done** — template vs config, presets, multiple versions, reset |
| Device log monitoring (Infinix X6853) | **Done** — no crashes; see Runtime QA below |

---

## Runtime QA (device browse — 2026-06-26)

| Check | Result |
|-------|--------|
| Crashes / `AndroidRuntime` fatals | None |
| BLoC error states | None |
| Navigation (Home, Settings, Calendar, Comments, Posts) | Normal cubit/bloc lifecycle |
| Dashboard 60s auto-refresh | Working |
| **UI overflow** | One **~12px bottom** `RenderFlex` on Home during AI Writer interaction (minor; fix pending) |

Non-app noise ignored: Infinix `/proc/report_rate_switch`, SLF4J, Impeller opt-out deprecation warning.

---

## App Health Summary (verified this session)

| Area | Status |
|------|--------|
| Compile / analyze | **Clean** (0 issues) |
| Tests | **27/27 passed** |
| Comment templates | **Working** (8 seeded categories, copy flow) |
| Posts / calendar / logs / reminders | **Working** (local-first) |
| AI Writer | **Working** (presets, template reset, copy/paste) |
| OAuth + API auto-post | **Partial** — code complete; needs developer app credentials + device OAuth test |
| Facebook API posting | **Pages only** (not personal profiles) |
| Scheduled background post | **Implemented** (~15 min WorkManager granularity) |

---

## Project Snapshot

| Key | Value |
|-----|-------|
| Package | `com.linkedif.socialbox` |
| Architecture | Clean Architecture · BLoC/Cubit · Drift · GoRouter · GetIt |
| DB schema | v2 (`hashtag_suggestions` table) |
| Bottom nav | Home · Calendar · Comments · Posts · Settings |
| Docs | `CLAUDE.md`, `features.md`, `schema.md`, `api.md`, `keys.md`, `agents.md`, `quickref.md`, `guide/` |

### Build (Windows, project on `I:`)

```powershell
$env:PUB_CACHE = "I:\.pub-cache"
Set-Location I:\Posts\socialbox
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run -d <device_id>
```

---

## Deferred to 2027 (intentionally out of scope)

| Area | Items |
|------|-------|
| API auto-posting | Recurring post auto-create executor |
| OAuth polish | Production credential testing on device; `features.md` page-picker note may be stale (picker exists in `AuthBloc`) |
| Polish | Lottie empty states, shimmer on all pages, app icon + splash, broader test coverage |
| Platform | Windows `main_windows.dart`, cloud sync, new platforms (Instagram, TikTok) |

---

## Known Pitfalls (avoid regressions)

| Issue | Safe approach |
|-------|---------------|
| AI Writer platform crash | Use `PromptConfig.normalizePlatform()` — values: `LinkedIn`, `X`, `Facebook` only |
| Cross-drive build fail | Set `$env:PUB_CACHE = "I:\.pub-cache"`; `kotlin.incremental=false` in `gradle.properties` |
| Drift changes | Bump `AppConstants.dbVersion`, add migration, run build_runner |
| Enum in SQLite | Store `SocialPlatform.name` / `PostStatus.name` — never `displayName` |

---

## Remaining Tech Debt (non-blocking)

- **~12px bottom overflow** on Home AI Writer area (device log; not in widget tests)
- `OnBackInvokedCallback` not enabled in manifest (Android 13+ back gesture warning)
- Impeller opt-out deprecation in `AndroidManifest.xml` (remove `EnableImpeller=false` when ready)
- Impeller/Vulkan GPU warnings on some devices
- ~~6 analyzer info-level lints~~ — **resolved** (`flutter analyze` 0 issues)
- `copy_feedback_snackbar.dart` spec widget never created (logic in `ClipboardService`)
- Export CSV uses `Share.share` only (no clipboard export)
- AI Writer: no in-app **template presets** (multiple master prompts); use Presets + external files (see `guide/ai-prompt-writer.md`)
- Shimmer/Lottie not on every screen; test coverage still growing (27 tests)

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
| `guide/README.md` | User guides index |
| `guide/social-media-auto-posting.md` | API auto-posting setup & platform limits |
| `guide/ai-prompt-writer.md` | AI template/config, presets, multiple versions |
| `STATUS.md` | This file — session state + gaps |

---

## Recent Git History (this release line)

| Commit | Summary |
|--------|---------|
| `e00ff0d` | AI prompt writer guide (presets, template versions, reset) |
| `a4cadb1` | Social media auto-posting guide (FB/LI/X, scheduling) |
| `cc7fb91` | Complete UI polish — all bottom sheets, extended screens, device QA |
| `6dc658c` | Modern polish pass — skeleton, settings/posts, PostListBloc fix |

---

*For implemented features and 2027 roadmap detail, see `features.md`.*