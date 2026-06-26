# SocialBox — Database Schema

**Source of truth:** `lib/core/database/app_database.dart`  
**Generated code:** `lib/core/database/app_database.g.dart` (run build_runner after any change)  
**DB file:** `{appDocuments}/socialbox.db`  
**Schema version:** `2` (`AppConstants.dbVersion`)

---

## Quick Rules (avoid common errors)

| Rule | Why |
|------|-----|
| Run `flutter pub run build_runner build --delete-conflicting-outputs` after table/DAO edits | Without `app_database.g.dart`, the project does not compile |
| Bump `AppConstants.dbVersion` and add `onUpgrade` step for every schema change | Existing installs need migrations |
| Store lists as JSON strings in `*Json` columns | `jsonEncode` on write, `jsonDecode` + `.cast<String>()` on read |
| Store enums as `.name` strings (`draft`, `facebook`, `posted`) | Never store `displayName` in DB |
| Platforms for posts live in junction table `social_post_platforms` | Not in `social_posts` row |
| Typedef row aliases use `*Row` suffix | e.g. `CommentRow`, `HashtagSuggestionRow` — avoids name clashes with domain entities |

---

## Entity Relationship (logical)

```
comment_categories 1──* comments

social_posts 1──* social_post_platforms
social_posts 1──* posting_logs
social_posts 1──* reminders (optional postId FK)

hashtag_suggestions (standalone, tag = PK)
```

---

## Tables

### `comment_categories`

| Column | Type | Notes |
|--------|------|-------|
| `id` | TEXT PK | UUID or predefined id e.g. `cat_engagement` |
| `name` | TEXT | Display name |
| `icon` | TEXT | Emoji |
| `colorHex` | TEXT | `#RRGGBB` |
| `isPredefined` | BOOL | `true` → cannot delete |
| `sortOrder` | INT | Grid order |
| `createdAt`, `updatedAt` | DATETIME | |

**Seed:** 8 predefined categories from `lib/core/constants/predefined_categories.dart` on `onCreate`.

---

### `comments`

| Column | Type | Notes |
|--------|------|-------|
| `id` | TEXT PK | UUID |
| `categoryId` | TEXT | FK → `comment_categories.id` (no Drift FK constraint in schema) |
| `commentText` | TEXT | Not named `text` (reserved) |
| `tagsJson` | TEXT | Default `[]` |
| `isFavorite` | BOOL | Default `false` |
| `usageCount` | INT | Incremented on copy |
| `createdAt`, `updatedAt` | DATETIME | |

**Seed:** 5 comments per predefined category on `onCreate`.

---

### `social_posts`

| Column | Type | Notes |
|--------|------|-------|
| `id` | TEXT PK | UUID |
| `title` | TEXT | Required in UI validation |
| `content` | TEXT | Post body |
| `status` | TEXT | `PostStatus.name`: `draft`, `scheduled`, `partial`, `posted`, `failed` |
| `scheduledAt` | DATETIME? | Future → `scheduled` |
| `isRecurring` | BOOL | |
| `recurringType` | TEXT | `RecurringType.name`: `none`, `daily`, `weekly`, `custom` |
| `recurringDaysJson` | TEXT | ISO weekdays `[1..7]` |
| `attachmentsJson` | TEXT | Local file paths |
| `tagsJson` | TEXT | Post tags |
| `notes` | TEXT? | Internal notes |
| `createdAt`, `updatedAt` | DATETIME | |

**Status logic (domain):** Compare targeted platforms (junction) vs `posting_logs` with `status = posted`.

---

### `social_post_platforms` (junction)

| Column | Type | Notes |
|--------|------|-------|
| `id` | INT PK AI | Auto-increment |
| `postId` | TEXT | FK → `social_posts.id` |
| `platform` | TEXT | `SocialPlatform.name`: `facebook`, `linkedin`, `twitter` |

Replaced entirely on post update (delete all rows for `postId`, re-insert).

---

### `posting_logs`

| Column | Type | Notes |
|--------|------|-------|
| `id` | TEXT PK | UUID |
| `postId` | TEXT | FK → `social_posts.id` |
| `platform` | TEXT | `SocialPlatform.name` |
| `status` | TEXT | `LogStatus.name`: `pending`, `posted`, `failed`, `skipped` |
| `method` | TEXT | `PostingMethod.name`: `manual`, `api` |
| `postedAt` | DATETIME? | When published |
| `externalPostId` | TEXT? | API response id |
| `externalPostUrl` | TEXT? | Live URL |
| `errorMessage` | TEXT? | API/manual failure |
| `notes` | TEXT? | User notes (manual flow) |
| `createdAt` | DATETIME | |

---

### `reminders`

| Column | Type | Notes |
|--------|------|-------|
| `id` | TEXT PK | UUID |
| `postId` | TEXT? | Optional link to post |
| `title` | TEXT | Notification title |
| `body` | TEXT? | Notification body |
| `scheduledAt` | DATETIME | Fire time |
| `repeat` | TEXT | `ReminderRepeat.name`: `none`, `daily`, `weekly`, `custom` |
| `repeatDaysJson` | TEXT | Custom repeat days |
| `isEnabled` | BOOL | Default `true` |
| `notificationId` | INT | `flutter_local_notifications` id |
| `createdAt`, `updatedAt` | DATETIME | |

---

### `hashtag_suggestions` (v2)

| Column | Type | Notes |
|--------|------|-------|
| `tag` | TEXT PK | Lowercase, no `#` prefix stored |
| `usageCount` | INT | Default `0` |
| `lastUsedAt` | DATETIME | |
| `createdAt` | DATETIME | |

**Migration v1 → v2:** `onUpgrade` creates this table when `from < 2`.

---

## DAOs

| DAO | Tables | Key methods |
|-----|--------|-------------|
| `CommentDao` | categories, comments | `watchAllCategories`, `searchComments`, `incrementUsageCount`, `toggleFavorite` |
| `PostDao` | posts, platforms | `insertPost`/`updatePost` (transaction + junction), `getPostsDueForPosting`, `getPostsInRange`, `getPlatformsForPost` |
| `LogDao` | posting_logs | `watchAllLogs`, `isPostedToday`, `getLogsForPost` |
| `ReminderDao` | reminders | `watchAllReminders`, `getRemindersInRange`, `toggleEnabled` |
| `HashtagDao` | hashtag_suggestions | `watchTopSuggestions`, `recordUsage`, `clearAll` |

---

## Migrations Checklist

When adding a table or column:

1. Edit table class in `app_database.dart`
2. Add DAO methods if needed
3. Register table/DAO in `@DriftDatabase(...)`
4. Increment `AppConstants.dbVersion`
5. Add `onUpgrade` branch in `MigrationStrategy`
6. Run build_runner
7. Test on a device with an existing DB (not just fresh install)

```dart
// Example pattern (already in codebase for v2)
onUpgrade: (m, from, to) async {
  if (from < 2) {
    await m.createTable(hashtagSuggestionsTable);
  }
  // if (from < 3) { ... }
},
```

---

## JSON Column Parsing

```dart
// Write
tagsJson: jsonEncode(['flutter', 'dart']),

// Read
final tags = (jsonDecode(row.tagsJson) as List).cast<String>();
```

---

## Related Docs

- `keys.md` — storage keys (not in SQLite)
- `api.md` — external APIs (posting logs reference platform names)
- `agents.md` — build commands and pitfalls
- `features.md` — feature status including hashtags & calendar