import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/predefined_categories.dart';

part 'app_database.g.dart';

const _uuid = Uuid();

// ============================================================================
// Drift Table Definitions
// ============================================================================

class CommentCategoriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  TextColumn get colorHex => text()();
  BoolColumn get isPredefined =>
      boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'comment_categories';
}

class CommentsTable extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text()();
  TextColumn get commentText => text()();
  TextColumn get tagsJson =>
      text().withDefault(const Constant('[]'))();
  BoolColumn get isFavorite =>
      boolean().withDefault(const Constant(false))();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'comments';
}

class SocialPostsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  BoolColumn get isRecurring =>
      boolean().withDefault(const Constant(false))();
  TextColumn get recurringType =>
      text().withDefault(const Constant('none'))();
  TextColumn get recurringDaysJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get attachmentsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'social_posts';
}

class SocialPostPlatformsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get postId => text()();
  TextColumn get platform => text()();

  @override
  String get tableName => 'social_post_platforms';
}

class PostingLogsTable extends Table {
  TextColumn get id => text()();
  TextColumn get postId => text()();
  TextColumn get platform => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get method => text().withDefault(const Constant('manual'))();
  DateTimeColumn get postedAt => dateTime().nullable()();
  TextColumn get externalPostId => text().nullable()();
  TextColumn get externalPostUrl => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'posting_logs';
}

class RemindersTable extends Table {
  TextColumn get id => text()();
  TextColumn get postId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get body => text().nullable()();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get repeat => text().withDefault(const Constant('none'))();
  TextColumn get repeatDaysJson =>
      text().withDefault(const Constant('[]'))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get notificationId => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'reminders';
}

class HashtagSuggestionsTable extends Table {
  TextColumn get tag => text()();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastUsedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {tag};

  @override
  String get tableName => 'hashtag_suggestions';
}

// ============================================================================
// Convenient row type aliases (avoid collision with generated class names)
// ============================================================================

typedef CommentCategoryRow = CommentCategoriesTableData;
typedef CommentRow = CommentsTableData;
typedef SocialPostRow = SocialPostsTableData;
typedef SocialPostPlatformRow = SocialPostPlatformsTableData;
typedef PostingLogRow = PostingLogsTableData;
typedef ReminderRow = RemindersTableData;
typedef HashtagSuggestionRow = HashtagSuggestionsTableData;

// ============================================================================
// DAOs
// ============================================================================

@DriftAccessor(tables: [CommentCategoriesTable, CommentsTable])
class CommentDao extends DatabaseAccessor<AppDatabase> with _$CommentDaoMixin {
  CommentDao(super.db);

  // Categories
  Stream<List<CommentCategoryRow>> watchAllCategories() =>
      (select(commentCategoriesTable)
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .watch();

  Future<List<CommentCategoryRow>> getAllCategories() =>
      (select(commentCategoriesTable)
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

  Future<CommentCategoryRow?> getCategoryById(String id) =>
      (select(commentCategoriesTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> insertCategory(CommentCategoriesTableCompanion entry) =>
      into(commentCategoriesTable).insert(entry);

  Future<bool> updateCategory(CommentCategoriesTableCompanion entry) =>
      update(commentCategoriesTable).replace(entry);

  Future<int> deleteCategory(String id) =>
      (delete(commentCategoriesTable)..where((t) => t.id.equals(id))).go();

  // Comments
  Stream<List<CommentRow>> watchByCategory(String categoryId) =>
      (select(commentsTable)
            ..where((t) => t.categoryId.equals(categoryId))
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.isFavorite, mode: OrderingMode.desc),
              (t) => OrderingTerm(
                  expression: t.usageCount, mode: OrderingMode.desc),
            ]))
          .watch();

  Future<List<CommentRow>> getByCategory(String categoryId) =>
      (select(commentsTable)
            ..where((t) => t.categoryId.equals(categoryId)))
          .get();

  Stream<List<CommentRow>> watchAllComments() => select(commentsTable).watch();

  Future<List<CommentRow>> getAllComments() => select(commentsTable).get();

  Future<List<CommentRow>> searchComments(String query) {
    final lower = query.toLowerCase();
    return (select(commentsTable)
          ..where((t) => t.commentText.lower().like('%$lower%')))
        .get();
  }

  Future<CommentRow?> getCommentById(String id) =>
      (select(commentsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> insertComment(CommentsTableCompanion entry) =>
      into(commentsTable).insert(entry);

  Future<bool> updateComment(CommentsTableCompanion entry) =>
      update(commentsTable).replace(entry);

  Future<int> deleteComment(String id) =>
      (delete(commentsTable)..where((t) => t.id.equals(id))).go();

  Future<void> toggleFavorite(String id) async {
    final current = await getCommentById(id);
    if (current == null) return;
    await (update(commentsTable)..where((t) => t.id.equals(id))).write(
      CommentsTableCompanion(
        isFavorite: Value(!current.isFavorite),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> incrementUsageCount(String id) async {
    final current = await getCommentById(id);
    if (current == null) return;
    await (update(commentsTable)..where((t) => t.id.equals(id))).write(
      CommentsTableCompanion(
        usageCount: Value(current.usageCount + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteCommentsByCategory(String categoryId) =>
      (delete(commentsTable)..where((t) => t.categoryId.equals(categoryId)))
          .go();
}

@DriftAccessor(tables: [SocialPostsTable, SocialPostPlatformsTable])
class PostDao extends DatabaseAccessor<AppDatabase> with _$PostDaoMixin {
  PostDao(super.db);

  Stream<List<SocialPostRow>> watchAllPosts() {
    final query = select(socialPostsTable)
      ..orderBy([
        (t) => OrderingTerm(
            expression: t.createdAt, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  Stream<List<SocialPostRow>> watchPostsByStatus(String status) {
    return (select(socialPostsTable)
          ..where((t) => t.status.equals(status))
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.scheduledAt, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  Future<List<SocialPostRow>> getPostsDueForPosting(DateTime now) async {
    final query = select(socialPostsTable)
      ..where((t) =>
          t.scheduledAt.isSmallerThanValue(now) &
          t.status.equals('scheduled'));
    return query.get();
  }

  Future<List<SocialPostRow>> getAllPosts() => select(socialPostsTable).get();

  Future<SocialPostRow?> getPostById(String id) =>
      (select(socialPostsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Stream<SocialPostRow?> watchPostById(String id) =>
      (select(socialPostsTable)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  Future<List<SocialPostRow>> getPostsInRange(DateTime start, DateTime end) {
    return (select(socialPostsTable)
          ..where((t) =>
              t.scheduledAt.isBiggerOrEqualValue(start) &
              t.scheduledAt.isSmallerThanValue(end))
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.scheduledAt, mode: OrderingMode.asc),
          ]))
        .get();
  }

  Future<void> insertPost(
    SocialPostsTableCompanion entry,
    List<String> platforms,
  ) async {
    await transaction(() async {
      await into(socialPostsTable).insert(entry);
      for (final p in platforms) {
        await into(socialPostPlatformsTable).insert(
          SocialPostPlatformsTableCompanion.insert(
              postId: entry.id.value, platform: p),
        );
      }
    });
  }

  Future<bool> updatePost(
    SocialPostsTableCompanion entry,
    List<String> platforms,
  ) async {
    return await transaction(() async {
      final updated = await update(socialPostsTable).replace(entry);
      await (delete(socialPostPlatformsTable)
            ..where((t) => t.postId.equals(entry.id.value)))
          .go();
      for (final p in platforms) {
        await into(socialPostPlatformsTable).insert(
          SocialPostPlatformsTableCompanion.insert(
              postId: entry.id.value, platform: p),
        );
      }
      return updated;
    });
  }

  Future<int> deletePost(String id) async {
    return await transaction(() async {
      await (delete(socialPostPlatformsTable)
            ..where((t) => t.postId.equals(id)))
          .go();
      return await (delete(socialPostsTable)..where((t) => t.id.equals(id)))
          .go();
    });
  }

  Future<void> updatePostStatus(String id, String status) =>
      (update(socialPostsTable)..where((t) => t.id.equals(id)))
          .write(SocialPostsTableCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ));

  Future<List<String>> getPlatformsForPost(String postId) async {
    final query = select(socialPostPlatformsTable)
      ..where((t) => t.postId.equals(postId));
    final rows = await query.get();
    return rows.map((r) => r.platform).toList();
  }

  Stream<List<String>> watchPlatformsForPost(String postId) {
    final query = select(socialPostPlatformsTable)
      ..where((t) => t.postId.equals(postId));
    return query
        .watch()
        .map((rows) => rows.map((r) => r.platform).toList());
  }
}

@DriftAccessor(tables: [PostingLogsTable])
class LogDao extends DatabaseAccessor<AppDatabase> with _$LogDaoMixin {
  LogDao(super.db);

  Stream<List<PostingLogRow>> watchAllLogs() {
    return (select(postingLogsTable)
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<List<PostingLogRow>> watchLogsForPost(String postId) {
    return (select(postingLogsTable)
          ..where((t) => t.postId.equals(postId))
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<List<PostingLogRow>> getAllLogs() {
    return (select(postingLogsTable)
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<List<PostingLogRow>> getLogsForPost(String postId) {
    return (select(postingLogsTable)
          ..where((t) => t.postId.equals(postId))
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<bool> isPostedToday(String postId, String platform) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final query = select(postingLogsTable)
      ..where((t) =>
          t.postId.equals(postId) &
          t.platform.equals(platform) &
          t.status.equals('posted') &
          t.createdAt.isBiggerOrEqualValue(startOfDay));
    final rows = await query.get();
    return rows.isNotEmpty;
  }

  Future<void> insertLog(PostingLogsTableCompanion entry) =>
      into(postingLogsTable).insert(entry);

  Future<bool> updateLog(PostingLogsTableCompanion entry) =>
      update(postingLogsTable).replace(entry);

  Future<int> deleteLog(String id) =>
      (delete(postingLogsTable)..where((t) => t.id.equals(id))).go();

  Future<int> deleteLogsForPost(String postId) =>
      (delete(postingLogsTable)..where((t) => t.postId.equals(postId))).go();
}

@DriftAccessor(tables: [RemindersTable])
class ReminderDao extends DatabaseAccessor<AppDatabase>
    with _$ReminderDaoMixin {
  ReminderDao(super.db);

  Stream<List<ReminderRow>> watchAllReminders() {
    return (select(remindersTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.scheduledAt),
          ]))
        .watch();
  }

  Stream<List<ReminderRow>> watchRemindersForPost(String postId) {
    return (select(remindersTable)
          ..where((t) => t.postId.equals(postId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.scheduledAt),
          ]))
        .watch();
  }

  Future<List<ReminderRow>> getAllReminders() {
    return (select(remindersTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.scheduledAt),
          ]))
        .get();
  }

  Future<ReminderRow?> getReminderById(String id) =>
      (select(remindersTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<List<ReminderRow>> getRemindersInRange(
      DateTime start, DateTime end) {
    return (select(remindersTable)
          ..where((t) =>
              t.scheduledAt.isBiggerOrEqualValue(start) &
              t.scheduledAt.isSmallerThanValue(end))
          ..orderBy([
            (t) => OrderingTerm(expression: t.scheduledAt),
          ]))
        .get();
  }

  Future<void> insertReminder(RemindersTableCompanion entry) =>
      into(remindersTable).insert(entry);

  Future<bool> updateReminder(RemindersTableCompanion entry) =>
      update(remindersTable).replace(entry);

  Future<int> deleteReminder(String id) =>
      (delete(remindersTable)..where((t) => t.id.equals(id))).go();

  Future<void> toggleEnabled(String id) async {
    final current = await getReminderById(id);
    if (current == null) return;
    await (update(remindersTable)..where((t) => t.id.equals(id))).write(
      RemindersTableCompanion(
        isEnabled: Value(!current.isEnabled),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteRemindersForPost(String postId) =>
      (delete(remindersTable)..where((t) => t.postId.equals(postId))).go();
}

// ============================================================================
// Root Database
// ============================================================================

@DriftAccessor(tables: [HashtagSuggestionsTable])
class HashtagDao extends DatabaseAccessor<AppDatabase>
    with _$HashtagDaoMixin {
  HashtagDao(super.db);

  Stream<List<HashtagSuggestionRow>> watchTopSuggestions({int limit = 30}) {
    return (select(hashtagSuggestionsTable)
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.usageCount, mode: OrderingMode.desc),
            (t) => OrderingTerm(
                expression: t.lastUsedAt, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .watch();
  }

  Future<List<HashtagSuggestionRow>> getTopSuggestions({int limit = 30}) {
    return (select(hashtagSuggestionsTable)
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.usageCount, mode: OrderingMode.desc),
            (t) => OrderingTerm(
                expression: t.lastUsedAt, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .get();
  }

  Future<HashtagSuggestionRow?> getByTag(String tag) =>
      (select(hashtagSuggestionsTable)..where((t) => t.tag.equals(tag)))
          .getSingleOrNull();

  Future<void> recordUsage(List<String> tags) async {
    if (tags.isEmpty) return;
    final now = DateTime.now();
    for (final tag in tags) {
      final clean = tag.trim().toLowerCase();
      if (clean.isEmpty) continue;
      final existing = await getByTag(clean);
      if (existing == null) {
        await into(hashtagSuggestionsTable).insert(
          HashtagSuggestionsTableCompanion.insert(
            tag: clean,
            usageCount: const Value(1),
            lastUsedAt: now,
            createdAt: now,
          ),
        );
      } else {
        await (update(hashtagSuggestionsTable)
              ..where((t) => t.tag.equals(clean)))
            .write(HashtagSuggestionsTableCompanion(
          usageCount: Value(existing.usageCount + 1),
          lastUsedAt: Value(now),
        ));
      }
    }
  }

  Future<void> clearAll() =>
      delete(hashtagSuggestionsTable).go();
}

@DriftDatabase(
  tables: [
    CommentCategoriesTable,
    CommentsTable,
    SocialPostsTable,
    SocialPostPlatformsTable,
    PostingLogsTable,
    RemindersTable,
    HashtagSuggestionsTable,
  ],
  daos: [CommentDao, PostDao, LogDao, ReminderDao, HashtagDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => AppConstants.dbVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedPredefinedData();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(hashtagSuggestionsTable);
          }
        },
      );

  Future<void> _seedPredefinedData() async {
    final now = DateTime.now();
    await batch((b) {
      for (var i = 0; i < kPredefinedCategories.length; i++) {
        final cat = kPredefinedCategories[i];
        b.insert(
          commentCategoriesTable,
          CommentCategoriesTableCompanion.insert(
            id: cat['id']!,
            name: cat['name']!,
            icon: cat['icon']!,
            colorHex: cat['color']!,
            isPredefined: const Value(true),
            sortOrder: Value(i),
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      kPredefinedComments.forEach((categoryId, comments) {
        for (final text in comments) {
          b.insert(
            commentsTable,
            CommentsTableCompanion.insert(
              id: _uuid.v4(),
              categoryId: categoryId,
              commentText: text,
              createdAt: now,
              updatedAt: now,
            ),
          );
        }
      });
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.dbName));
    return NativeDatabase.createInBackground(file);
  });
}
