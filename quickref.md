# SocialBox — Quick Reference

One-page cheat sheet. Details: `agents.md`, `schema.md`, `api.md`, `keys.md`, `CLAUDE.md`.

---

## Identity

| | |
|-|-|
| Package | `com.linkedif.socialbox` |
| DB | `socialbox.db` · schema **v2** |
| Stack | Flutter · Features-First Clean Arch · MVVM · BLoC/Cubit · Drift · GoRouter |

---

## Build & Run (Windows, `I:` drive)

```powershell
$env:PUB_CACHE = "I:\.pub-cache"
Set-Location I:\Posts\socialbox
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run -d <device_id>
```

After **any** Drift table/DAO change → build_runner.

---

## Architecture (Features-First + MVVM + BLoC/Cubit)

```
View (pages/widgets) → ViewModel (Bloc/Cubit) → UseCase → Repository → DataSource
```

| MVVM | Folder |
|------|--------|
| Model | `domain/entities/` |
| ViewModel | `presentation/bloc/` or `presentation/cubit/` |
| View | `presentation/pages/`, `widgets/` |

**Bloc vs Cubit:** Cubit = simple methods (`load`, `save`). Bloc = multi-event flows (auth, reminders, post list).

**Rules:** Domain = pure Dart · DI in `injection_container.dart` only · Views use `context.read<>()` — never `getIt` in widgets.

**Expansion policy:** Fixes and features **add or wire** — never delete screens, routes, DB fields, or behavior to compile. See `CLAUDE.md` §2.

---

## Routes

| Tab / screen | Path |
|--------------|------|
| Dashboard | `/dashboard` |
| Calendar | `/calendar` |
| Comments | `/comments` → `/comments/:categoryId` |
| Posts | `/posts` → `/posts/new`, `/posts/:id` |
| Settings | `/settings` → `/settings/accounts`, `/settings/reminders` |
| AI Writer | `/ai-writer` |
| Posting Log | `/logs` *(no nav link)* |

---

## Platform strings (do not mix)

| Layer | Facebook | LinkedIn | Twitter/X |
|-------|----------|----------|-----------|
| DB / enum `.name` | `facebook` | `linkedin` | `twitter` |
| UI `displayName` | `Facebook` | `LinkedIn` | `Twitter / X` |
| AI Writer dropdown | `Facebook` | `LinkedIn` | `X` |

```dart
PromptConfig.normalizePlatform(value)
PromptConfig.platformFromSocial(SocialPlatform.twitter) // → 'X'
```

---

## DB tables (7)

`comment_categories` · `comments` · `social_posts` · `social_post_platforms` · `posting_logs` · `reminders` · `hashtag_suggestions`

Lists → JSON text columns (`tagsJson`, `recurringDaysJson`, …). Enums → `.name` strings.

---

## Storage keys

| Store | Key | Content |
|-------|-----|---------|
| Secure | `socialbox_oauth_{platform}` | OAuth token JSON |
| Secure | `socialbox_oauth_{platform}_cid` / `_cs` | Client id / secret |
| Prefs | `socialbox_settings` | App settings JSON |
| Prefs | `socialbox_prompt_template` | AI prompt template |
| Prefs | `socialbox_prompt_last_config` | Last PromptConfig |
| Prefs | `socialbox_prompt_presets` | AI presets |

OAuth redirects: `com.linkedif.socialbox://oauth/{twitter|linkedin|facebook}`

---

## Top pitfalls

1. **AI crash** — never use `displayName` in AI dropdown; use `normalizePlatform()`
2. **No compile** — run build_runner if `app_database.g.dart` missing
3. **Kotlin fail** — set `PUB_CACHE` on `I:\`, `kotlin.incremental=false`
4. **Settings toggles** — saved but not all wired to behavior yet
5. **Notifications** — tap → navigate not wired in `main.dart`
6. **API posting** — OAuth partial; auto-post scheduled 2027

---

## Doc map

| Need | Read |
|------|------|
| Full architecture | `CLAUDE.md` |
| Agent workflow | `agents.md` |
| Tables & migrations | `schema.md` |
| OAuth & APIs | `api.md` |
| Keys & secrets | `keys.md` |
| Feature status | `features.md` |
| Session issues | `STATUS.md` |

*Updated: 2026-06-26 — MVVM + mixed BLoC/Cubit + expansion policy*