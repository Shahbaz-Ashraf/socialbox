// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
mixin _$CommentDaoMixin on DatabaseAccessor<AppDatabase> {
  $CommentCategoriesTableTable get commentCategoriesTable =>
      attachedDatabase.commentCategoriesTable;
  $CommentsTableTable get commentsTable => attachedDatabase.commentsTable;
  CommentDaoManager get managers => CommentDaoManager(this);
}

class CommentDaoManager {
  final _$CommentDaoMixin _db;
  CommentDaoManager(this._db);
  $$CommentCategoriesTableTableTableManager get commentCategoriesTable =>
      $$CommentCategoriesTableTableTableManager(
          _db.attachedDatabase, _db.commentCategoriesTable);
  $$CommentsTableTableTableManager get commentsTable =>
      $$CommentsTableTableTableManager(_db.attachedDatabase, _db.commentsTable);
}

mixin _$PostDaoMixin on DatabaseAccessor<AppDatabase> {
  $SocialPostsTableTable get socialPostsTable =>
      attachedDatabase.socialPostsTable;
  $SocialPostPlatformsTableTable get socialPostPlatformsTable =>
      attachedDatabase.socialPostPlatformsTable;
  PostDaoManager get managers => PostDaoManager(this);
}

class PostDaoManager {
  final _$PostDaoMixin _db;
  PostDaoManager(this._db);
  $$SocialPostsTableTableTableManager get socialPostsTable =>
      $$SocialPostsTableTableTableManager(
          _db.attachedDatabase, _db.socialPostsTable);
  $$SocialPostPlatformsTableTableTableManager get socialPostPlatformsTable =>
      $$SocialPostPlatformsTableTableTableManager(
          _db.attachedDatabase, _db.socialPostPlatformsTable);
}

mixin _$LogDaoMixin on DatabaseAccessor<AppDatabase> {
  $PostingLogsTableTable get postingLogsTable =>
      attachedDatabase.postingLogsTable;
  LogDaoManager get managers => LogDaoManager(this);
}

class LogDaoManager {
  final _$LogDaoMixin _db;
  LogDaoManager(this._db);
  $$PostingLogsTableTableTableManager get postingLogsTable =>
      $$PostingLogsTableTableTableManager(
          _db.attachedDatabase, _db.postingLogsTable);
}

mixin _$ReminderDaoMixin on DatabaseAccessor<AppDatabase> {
  $RemindersTableTable get remindersTable => attachedDatabase.remindersTable;
  ReminderDaoManager get managers => ReminderDaoManager(this);
}

class ReminderDaoManager {
  final _$ReminderDaoMixin _db;
  ReminderDaoManager(this._db);
  $$RemindersTableTableTableManager get remindersTable =>
      $$RemindersTableTableTableManager(
          _db.attachedDatabase, _db.remindersTable);
}

mixin _$HashtagDaoMixin on DatabaseAccessor<AppDatabase> {
  $HashtagSuggestionsTableTable get hashtagSuggestionsTable =>
      attachedDatabase.hashtagSuggestionsTable;
  HashtagDaoManager get managers => HashtagDaoManager(this);
}

class HashtagDaoManager {
  final _$HashtagDaoMixin _db;
  HashtagDaoManager(this._db);
  $$HashtagSuggestionsTableTableTableManager get hashtagSuggestionsTable =>
      $$HashtagSuggestionsTableTableTableManager(
          _db.attachedDatabase, _db.hashtagSuggestionsTable);
}

class $CommentCategoriesTableTable extends CommentCategoriesTable
    with TableInfo<$CommentCategoriesTableTable, CommentCategoriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommentCategoriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
      'color_hex', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isPredefinedMeta =
      const VerificationMeta('isPredefined');
  @override
  late final GeneratedColumn<bool> isPredefined = GeneratedColumn<bool>(
      'is_predefined', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_predefined" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, icon, colorHex, isPredefined, sortOrder, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'comment_categories';
  @override
  VerificationContext validateIntegrity(
      Insertable<CommentCategoriesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('is_predefined')) {
      context.handle(
          _isPredefinedMeta,
          isPredefined.isAcceptableOrUnknown(
              data['is_predefined']!, _isPredefinedMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CommentCategoriesTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommentCategoriesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_hex'])!,
      isPredefined: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_predefined'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CommentCategoriesTableTable createAlias(String alias) {
    return $CommentCategoriesTableTable(attachedDatabase, alias);
  }
}

class CommentCategoriesTableData extends DataClass
    implements Insertable<CommentCategoriesTableData> {
  final String id;
  final String name;
  final String icon;
  final String colorHex;
  final bool isPredefined;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CommentCategoriesTableData(
      {required this.id,
      required this.name,
      required this.icon,
      required this.colorHex,
      required this.isPredefined,
      required this.sortOrder,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color_hex'] = Variable<String>(colorHex);
    map['is_predefined'] = Variable<bool>(isPredefined);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CommentCategoriesTableCompanion toCompanion(bool nullToAbsent) {
    return CommentCategoriesTableCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      colorHex: Value(colorHex),
      isPredefined: Value(isPredefined),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CommentCategoriesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommentCategoriesTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      isPredefined: serializer.fromJson<bool>(json['isPredefined']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'colorHex': serializer.toJson<String>(colorHex),
      'isPredefined': serializer.toJson<bool>(isPredefined),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CommentCategoriesTableData copyWith(
          {String? id,
          String? name,
          String? icon,
          String? colorHex,
          bool? isPredefined,
          int? sortOrder,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CommentCategoriesTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        colorHex: colorHex ?? this.colorHex,
        isPredefined: isPredefined ?? this.isPredefined,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CommentCategoriesTableData copyWithCompanion(
      CommentCategoriesTableCompanion data) {
    return CommentCategoriesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      isPredefined: data.isPredefined.present
          ? data.isPredefined.value
          : this.isPredefined,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommentCategoriesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('colorHex: $colorHex, ')
          ..write('isPredefined: $isPredefined, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, icon, colorHex, isPredefined, sortOrder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommentCategoriesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.colorHex == this.colorHex &&
          other.isPredefined == this.isPredefined &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CommentCategoriesTableCompanion
    extends UpdateCompanion<CommentCategoriesTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<String> colorHex;
  final Value<bool> isPredefined;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CommentCategoriesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isPredefined = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommentCategoriesTableCompanion.insert({
    required String id,
    required String name,
    required String icon,
    required String colorHex,
    this.isPredefined = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        icon = Value(icon),
        colorHex = Value(colorHex),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CommentCategoriesTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? colorHex,
    Expression<bool>? isPredefined,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (colorHex != null) 'color_hex': colorHex,
      if (isPredefined != null) 'is_predefined': isPredefined,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommentCategoriesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? icon,
      Value<String>? colorHex,
      Value<bool>? isPredefined,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CommentCategoriesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      isPredefined: isPredefined ?? this.isPredefined,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (isPredefined.present) {
      map['is_predefined'] = Variable<bool>(isPredefined.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommentCategoriesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('colorHex: $colorHex, ')
          ..write('isPredefined: $isPredefined, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommentsTableTable extends CommentsTable
    with TableInfo<$CommentsTableTable, CommentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _commentTextMeta =
      const VerificationMeta('commentText');
  @override
  late final GeneratedColumn<String> commentText = GeneratedColumn<String>(
      'comment_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagsJsonMeta =
      const VerificationMeta('tagsJson');
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
      'tags_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _usageCountMeta =
      const VerificationMeta('usageCount');
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
      'usage_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        categoryId,
        commentText,
        tagsJson,
        isFavorite,
        usageCount,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'comments';
  @override
  VerificationContext validateIntegrity(Insertable<CommentsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('comment_text')) {
      context.handle(
          _commentTextMeta,
          commentText.isAcceptableOrUnknown(
              data['comment_text']!, _commentTextMeta));
    } else if (isInserting) {
      context.missing(_commentTextMeta);
    }
    if (data.containsKey('tags_json')) {
      context.handle(_tagsJsonMeta,
          tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('usage_count')) {
      context.handle(
          _usageCountMeta,
          usageCount.isAcceptableOrUnknown(
              data['usage_count']!, _usageCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CommentsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommentsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      commentText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comment_text'])!,
      tagsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags_json'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      usageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}usage_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CommentsTableTable createAlias(String alias) {
    return $CommentsTableTable(attachedDatabase, alias);
  }
}

class CommentsTableData extends DataClass
    implements Insertable<CommentsTableData> {
  final String id;
  final String categoryId;
  final String commentText;
  final String tagsJson;
  final bool isFavorite;
  final int usageCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CommentsTableData(
      {required this.id,
      required this.categoryId,
      required this.commentText,
      required this.tagsJson,
      required this.isFavorite,
      required this.usageCount,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['comment_text'] = Variable<String>(commentText);
    map['tags_json'] = Variable<String>(tagsJson);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['usage_count'] = Variable<int>(usageCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CommentsTableCompanion toCompanion(bool nullToAbsent) {
    return CommentsTableCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      commentText: Value(commentText),
      tagsJson: Value(tagsJson),
      isFavorite: Value(isFavorite),
      usageCount: Value(usageCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CommentsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommentsTableData(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      commentText: serializer.fromJson<String>(json['commentText']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'commentText': serializer.toJson<String>(commentText),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'usageCount': serializer.toJson<int>(usageCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CommentsTableData copyWith(
          {String? id,
          String? categoryId,
          String? commentText,
          String? tagsJson,
          bool? isFavorite,
          int? usageCount,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CommentsTableData(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        commentText: commentText ?? this.commentText,
        tagsJson: tagsJson ?? this.tagsJson,
        isFavorite: isFavorite ?? this.isFavorite,
        usageCount: usageCount ?? this.usageCount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CommentsTableData copyWithCompanion(CommentsTableCompanion data) {
    return CommentsTableData(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      commentText:
          data.commentText.present ? data.commentText.value : this.commentText,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      usageCount:
          data.usageCount.present ? data.usageCount.value : this.usageCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommentsTableData(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('commentText: $commentText, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('usageCount: $usageCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryId, commentText, tagsJson,
      isFavorite, usageCount, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommentsTableData &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.commentText == this.commentText &&
          other.tagsJson == this.tagsJson &&
          other.isFavorite == this.isFavorite &&
          other.usageCount == this.usageCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CommentsTableCompanion extends UpdateCompanion<CommentsTableData> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<String> commentText;
  final Value<String> tagsJson;
  final Value<bool> isFavorite;
  final Value<int> usageCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CommentsTableCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.commentText = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommentsTableCompanion.insert({
    required String id,
    required String categoryId,
    required String commentText,
    this.tagsJson = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.usageCount = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        categoryId = Value(categoryId),
        commentText = Value(commentText),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CommentsTableData> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<String>? commentText,
    Expression<String>? tagsJson,
    Expression<bool>? isFavorite,
    Expression<int>? usageCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (commentText != null) 'comment_text': commentText,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (usageCount != null) 'usage_count': usageCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommentsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? categoryId,
      Value<String>? commentText,
      Value<String>? tagsJson,
      Value<bool>? isFavorite,
      Value<int>? usageCount,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CommentsTableCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      commentText: commentText ?? this.commentText,
      tagsJson: tagsJson ?? this.tagsJson,
      isFavorite: isFavorite ?? this.isFavorite,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (commentText.present) {
      map['comment_text'] = Variable<String>(commentText.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommentsTableCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('commentText: $commentText, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('usageCount: $usageCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SocialPostsTableTable extends SocialPostsTable
    with TableInfo<$SocialPostsTableTable, SocialPostsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SocialPostsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('draft'));
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
      'scheduled_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isRecurringMeta =
      const VerificationMeta('isRecurring');
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
      'is_recurring', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_recurring" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _recurringTypeMeta =
      const VerificationMeta('recurringType');
  @override
  late final GeneratedColumn<String> recurringType = GeneratedColumn<String>(
      'recurring_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('none'));
  static const VerificationMeta _recurringDaysJsonMeta =
      const VerificationMeta('recurringDaysJson');
  @override
  late final GeneratedColumn<String> recurringDaysJson =
      GeneratedColumn<String>('recurring_days_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _attachmentsJsonMeta =
      const VerificationMeta('attachmentsJson');
  @override
  late final GeneratedColumn<String> attachmentsJson = GeneratedColumn<String>(
      'attachments_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _tagsJsonMeta =
      const VerificationMeta('tagsJson');
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
      'tags_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        content,
        status,
        scheduledAt,
        isRecurring,
        recurringType,
        recurringDaysJson,
        attachmentsJson,
        tagsJson,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'social_posts';
  @override
  VerificationContext validateIntegrity(
      Insertable<SocialPostsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
          _isRecurringMeta,
          isRecurring.isAcceptableOrUnknown(
              data['is_recurring']!, _isRecurringMeta));
    }
    if (data.containsKey('recurring_type')) {
      context.handle(
          _recurringTypeMeta,
          recurringType.isAcceptableOrUnknown(
              data['recurring_type']!, _recurringTypeMeta));
    }
    if (data.containsKey('recurring_days_json')) {
      context.handle(
          _recurringDaysJsonMeta,
          recurringDaysJson.isAcceptableOrUnknown(
              data['recurring_days_json']!, _recurringDaysJsonMeta));
    }
    if (data.containsKey('attachments_json')) {
      context.handle(
          _attachmentsJsonMeta,
          attachmentsJson.isAcceptableOrUnknown(
              data['attachments_json']!, _attachmentsJsonMeta));
    }
    if (data.containsKey('tags_json')) {
      context.handle(_tagsJsonMeta,
          tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SocialPostsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SocialPostsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scheduled_at']),
      isRecurring: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_recurring'])!,
      recurringType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurring_type'])!,
      recurringDaysJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recurring_days_json'])!,
      attachmentsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}attachments_json'])!,
      tagsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags_json'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SocialPostsTableTable createAlias(String alias) {
    return $SocialPostsTableTable(attachedDatabase, alias);
  }
}

class SocialPostsTableData extends DataClass
    implements Insertable<SocialPostsTableData> {
  final String id;
  final String title;
  final String content;
  final String status;
  final DateTime? scheduledAt;
  final bool isRecurring;
  final String recurringType;
  final String recurringDaysJson;
  final String attachmentsJson;
  final String tagsJson;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SocialPostsTableData(
      {required this.id,
      required this.title,
      required this.content,
      required this.status,
      this.scheduledAt,
      required this.isRecurring,
      required this.recurringType,
      required this.recurringDaysJson,
      required this.attachmentsJson,
      required this.tagsJson,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    map['is_recurring'] = Variable<bool>(isRecurring);
    map['recurring_type'] = Variable<String>(recurringType);
    map['recurring_days_json'] = Variable<String>(recurringDaysJson);
    map['attachments_json'] = Variable<String>(attachmentsJson);
    map['tags_json'] = Variable<String>(tagsJson);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SocialPostsTableCompanion toCompanion(bool nullToAbsent) {
    return SocialPostsTableCompanion(
      id: Value(id),
      title: Value(title),
      content: Value(content),
      status: Value(status),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      isRecurring: Value(isRecurring),
      recurringType: Value(recurringType),
      recurringDaysJson: Value(recurringDaysJson),
      attachmentsJson: Value(attachmentsJson),
      tagsJson: Value(tagsJson),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SocialPostsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SocialPostsTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      status: serializer.fromJson<String>(json['status']),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      recurringType: serializer.fromJson<String>(json['recurringType']),
      recurringDaysJson: serializer.fromJson<String>(json['recurringDaysJson']),
      attachmentsJson: serializer.fromJson<String>(json['attachmentsJson']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'status': serializer.toJson<String>(status),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'recurringType': serializer.toJson<String>(recurringType),
      'recurringDaysJson': serializer.toJson<String>(recurringDaysJson),
      'attachmentsJson': serializer.toJson<String>(attachmentsJson),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SocialPostsTableData copyWith(
          {String? id,
          String? title,
          String? content,
          String? status,
          Value<DateTime?> scheduledAt = const Value.absent(),
          bool? isRecurring,
          String? recurringType,
          String? recurringDaysJson,
          String? attachmentsJson,
          String? tagsJson,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      SocialPostsTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        status: status ?? this.status,
        scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
        isRecurring: isRecurring ?? this.isRecurring,
        recurringType: recurringType ?? this.recurringType,
        recurringDaysJson: recurringDaysJson ?? this.recurringDaysJson,
        attachmentsJson: attachmentsJson ?? this.attachmentsJson,
        tagsJson: tagsJson ?? this.tagsJson,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SocialPostsTableData copyWithCompanion(SocialPostsTableCompanion data) {
    return SocialPostsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      status: data.status.present ? data.status.value : this.status,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      isRecurring:
          data.isRecurring.present ? data.isRecurring.value : this.isRecurring,
      recurringType: data.recurringType.present
          ? data.recurringType.value
          : this.recurringType,
      recurringDaysJson: data.recurringDaysJson.present
          ? data.recurringDaysJson.value
          : this.recurringDaysJson,
      attachmentsJson: data.attachmentsJson.present
          ? data.attachmentsJson.value
          : this.attachmentsJson,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SocialPostsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('status: $status, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurringType: $recurringType, ')
          ..write('recurringDaysJson: $recurringDaysJson, ')
          ..write('attachmentsJson: $attachmentsJson, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      content,
      status,
      scheduledAt,
      isRecurring,
      recurringType,
      recurringDaysJson,
      attachmentsJson,
      tagsJson,
      notes,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SocialPostsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.content == this.content &&
          other.status == this.status &&
          other.scheduledAt == this.scheduledAt &&
          other.isRecurring == this.isRecurring &&
          other.recurringType == this.recurringType &&
          other.recurringDaysJson == this.recurringDaysJson &&
          other.attachmentsJson == this.attachmentsJson &&
          other.tagsJson == this.tagsJson &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SocialPostsTableCompanion extends UpdateCompanion<SocialPostsTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> content;
  final Value<String> status;
  final Value<DateTime?> scheduledAt;
  final Value<bool> isRecurring;
  final Value<String> recurringType;
  final Value<String> recurringDaysJson;
  final Value<String> attachmentsJson;
  final Value<String> tagsJson;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SocialPostsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.status = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurringType = const Value.absent(),
    this.recurringDaysJson = const Value.absent(),
    this.attachmentsJson = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SocialPostsTableCompanion.insert({
    required String id,
    required String title,
    required String content,
    this.status = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurringType = const Value.absent(),
    this.recurringDaysJson = const Value.absent(),
    this.attachmentsJson = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        content = Value(content),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<SocialPostsTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? status,
    Expression<DateTime>? scheduledAt,
    Expression<bool>? isRecurring,
    Expression<String>? recurringType,
    Expression<String>? recurringDaysJson,
    Expression<String>? attachmentsJson,
    Expression<String>? tagsJson,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (status != null) 'status': status,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (recurringType != null) 'recurring_type': recurringType,
      if (recurringDaysJson != null) 'recurring_days_json': recurringDaysJson,
      if (attachmentsJson != null) 'attachments_json': attachmentsJson,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SocialPostsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? content,
      Value<String>? status,
      Value<DateTime?>? scheduledAt,
      Value<bool>? isRecurring,
      Value<String>? recurringType,
      Value<String>? recurringDaysJson,
      Value<String>? attachmentsJson,
      Value<String>? tagsJson,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SocialPostsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      recurringDaysJson: recurringDaysJson ?? this.recurringDaysJson,
      attachmentsJson: attachmentsJson ?? this.attachmentsJson,
      tagsJson: tagsJson ?? this.tagsJson,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (recurringType.present) {
      map['recurring_type'] = Variable<String>(recurringType.value);
    }
    if (recurringDaysJson.present) {
      map['recurring_days_json'] = Variable<String>(recurringDaysJson.value);
    }
    if (attachmentsJson.present) {
      map['attachments_json'] = Variable<String>(attachmentsJson.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SocialPostsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('status: $status, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurringType: $recurringType, ')
          ..write('recurringDaysJson: $recurringDaysJson, ')
          ..write('attachmentsJson: $attachmentsJson, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SocialPostPlatformsTableTable extends SocialPostPlatformsTable
    with
        TableInfo<$SocialPostPlatformsTableTable,
            SocialPostPlatformsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SocialPostPlatformsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _postIdMeta = const VerificationMeta('postId');
  @override
  late final GeneratedColumn<String> postId = GeneratedColumn<String>(
      'post_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _platformMeta =
      const VerificationMeta('platform');
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
      'platform', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, postId, platform];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'social_post_platforms';
  @override
  VerificationContext validateIntegrity(
      Insertable<SocialPostPlatformsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('post_id')) {
      context.handle(_postIdMeta,
          postId.isAcceptableOrUnknown(data['post_id']!, _postIdMeta));
    } else if (isInserting) {
      context.missing(_postIdMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(_platformMeta,
          platform.isAcceptableOrUnknown(data['platform']!, _platformMeta));
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SocialPostPlatformsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SocialPostPlatformsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      postId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}post_id'])!,
      platform: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}platform'])!,
    );
  }

  @override
  $SocialPostPlatformsTableTable createAlias(String alias) {
    return $SocialPostPlatformsTableTable(attachedDatabase, alias);
  }
}

class SocialPostPlatformsTableData extends DataClass
    implements Insertable<SocialPostPlatformsTableData> {
  final int id;
  final String postId;
  final String platform;
  const SocialPostPlatformsTableData(
      {required this.id, required this.postId, required this.platform});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['post_id'] = Variable<String>(postId);
    map['platform'] = Variable<String>(platform);
    return map;
  }

  SocialPostPlatformsTableCompanion toCompanion(bool nullToAbsent) {
    return SocialPostPlatformsTableCompanion(
      id: Value(id),
      postId: Value(postId),
      platform: Value(platform),
    );
  }

  factory SocialPostPlatformsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SocialPostPlatformsTableData(
      id: serializer.fromJson<int>(json['id']),
      postId: serializer.fromJson<String>(json['postId']),
      platform: serializer.fromJson<String>(json['platform']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'postId': serializer.toJson<String>(postId),
      'platform': serializer.toJson<String>(platform),
    };
  }

  SocialPostPlatformsTableData copyWith(
          {int? id, String? postId, String? platform}) =>
      SocialPostPlatformsTableData(
        id: id ?? this.id,
        postId: postId ?? this.postId,
        platform: platform ?? this.platform,
      );
  SocialPostPlatformsTableData copyWithCompanion(
      SocialPostPlatformsTableCompanion data) {
    return SocialPostPlatformsTableData(
      id: data.id.present ? data.id.value : this.id,
      postId: data.postId.present ? data.postId.value : this.postId,
      platform: data.platform.present ? data.platform.value : this.platform,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SocialPostPlatformsTableData(')
          ..write('id: $id, ')
          ..write('postId: $postId, ')
          ..write('platform: $platform')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, postId, platform);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SocialPostPlatformsTableData &&
          other.id == this.id &&
          other.postId == this.postId &&
          other.platform == this.platform);
}

class SocialPostPlatformsTableCompanion
    extends UpdateCompanion<SocialPostPlatformsTableData> {
  final Value<int> id;
  final Value<String> postId;
  final Value<String> platform;
  const SocialPostPlatformsTableCompanion({
    this.id = const Value.absent(),
    this.postId = const Value.absent(),
    this.platform = const Value.absent(),
  });
  SocialPostPlatformsTableCompanion.insert({
    this.id = const Value.absent(),
    required String postId,
    required String platform,
  })  : postId = Value(postId),
        platform = Value(platform);
  static Insertable<SocialPostPlatformsTableData> custom({
    Expression<int>? id,
    Expression<String>? postId,
    Expression<String>? platform,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (postId != null) 'post_id': postId,
      if (platform != null) 'platform': platform,
    });
  }

  SocialPostPlatformsTableCompanion copyWith(
      {Value<int>? id, Value<String>? postId, Value<String>? platform}) {
    return SocialPostPlatformsTableCompanion(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      platform: platform ?? this.platform,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (postId.present) {
      map['post_id'] = Variable<String>(postId.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SocialPostPlatformsTableCompanion(')
          ..write('id: $id, ')
          ..write('postId: $postId, ')
          ..write('platform: $platform')
          ..write(')'))
        .toString();
  }
}

class $PostingLogsTableTable extends PostingLogsTable
    with TableInfo<$PostingLogsTableTable, PostingLogsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostingLogsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _postIdMeta = const VerificationMeta('postId');
  @override
  late final GeneratedColumn<String> postId = GeneratedColumn<String>(
      'post_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _platformMeta =
      const VerificationMeta('platform');
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
      'platform', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('manual'));
  static const VerificationMeta _postedAtMeta =
      const VerificationMeta('postedAt');
  @override
  late final GeneratedColumn<DateTime> postedAt = GeneratedColumn<DateTime>(
      'posted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _externalPostIdMeta =
      const VerificationMeta('externalPostId');
  @override
  late final GeneratedColumn<String> externalPostId = GeneratedColumn<String>(
      'external_post_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _externalPostUrlMeta =
      const VerificationMeta('externalPostUrl');
  @override
  late final GeneratedColumn<String> externalPostUrl = GeneratedColumn<String>(
      'external_post_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        postId,
        platform,
        status,
        method,
        postedAt,
        externalPostId,
        externalPostUrl,
        errorMessage,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'posting_logs';
  @override
  VerificationContext validateIntegrity(
      Insertable<PostingLogsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('post_id')) {
      context.handle(_postIdMeta,
          postId.isAcceptableOrUnknown(data['post_id']!, _postIdMeta));
    } else if (isInserting) {
      context.missing(_postIdMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(_platformMeta,
          platform.isAcceptableOrUnknown(data['platform']!, _platformMeta));
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    }
    if (data.containsKey('posted_at')) {
      context.handle(_postedAtMeta,
          postedAt.isAcceptableOrUnknown(data['posted_at']!, _postedAtMeta));
    }
    if (data.containsKey('external_post_id')) {
      context.handle(
          _externalPostIdMeta,
          externalPostId.isAcceptableOrUnknown(
              data['external_post_id']!, _externalPostIdMeta));
    }
    if (data.containsKey('external_post_url')) {
      context.handle(
          _externalPostUrlMeta,
          externalPostUrl.isAcceptableOrUnknown(
              data['external_post_url']!, _externalPostUrlMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PostingLogsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PostingLogsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      postId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}post_id'])!,
      platform: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}platform'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      postedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}posted_at']),
      externalPostId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}external_post_id']),
      externalPostUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}external_post_url']),
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PostingLogsTableTable createAlias(String alias) {
    return $PostingLogsTableTable(attachedDatabase, alias);
  }
}

class PostingLogsTableData extends DataClass
    implements Insertable<PostingLogsTableData> {
  final String id;
  final String postId;
  final String platform;
  final String status;
  final String method;
  final DateTime? postedAt;
  final String? externalPostId;
  final String? externalPostUrl;
  final String? errorMessage;
  final String? notes;
  final DateTime createdAt;
  const PostingLogsTableData(
      {required this.id,
      required this.postId,
      required this.platform,
      required this.status,
      required this.method,
      this.postedAt,
      this.externalPostId,
      this.externalPostUrl,
      this.errorMessage,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['post_id'] = Variable<String>(postId);
    map['platform'] = Variable<String>(platform);
    map['status'] = Variable<String>(status);
    map['method'] = Variable<String>(method);
    if (!nullToAbsent || postedAt != null) {
      map['posted_at'] = Variable<DateTime>(postedAt);
    }
    if (!nullToAbsent || externalPostId != null) {
      map['external_post_id'] = Variable<String>(externalPostId);
    }
    if (!nullToAbsent || externalPostUrl != null) {
      map['external_post_url'] = Variable<String>(externalPostUrl);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PostingLogsTableCompanion toCompanion(bool nullToAbsent) {
    return PostingLogsTableCompanion(
      id: Value(id),
      postId: Value(postId),
      platform: Value(platform),
      status: Value(status),
      method: Value(method),
      postedAt: postedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(postedAt),
      externalPostId: externalPostId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalPostId),
      externalPostUrl: externalPostUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(externalPostUrl),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory PostingLogsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PostingLogsTableData(
      id: serializer.fromJson<String>(json['id']),
      postId: serializer.fromJson<String>(json['postId']),
      platform: serializer.fromJson<String>(json['platform']),
      status: serializer.fromJson<String>(json['status']),
      method: serializer.fromJson<String>(json['method']),
      postedAt: serializer.fromJson<DateTime?>(json['postedAt']),
      externalPostId: serializer.fromJson<String?>(json['externalPostId']),
      externalPostUrl: serializer.fromJson<String?>(json['externalPostUrl']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'postId': serializer.toJson<String>(postId),
      'platform': serializer.toJson<String>(platform),
      'status': serializer.toJson<String>(status),
      'method': serializer.toJson<String>(method),
      'postedAt': serializer.toJson<DateTime?>(postedAt),
      'externalPostId': serializer.toJson<String?>(externalPostId),
      'externalPostUrl': serializer.toJson<String?>(externalPostUrl),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PostingLogsTableData copyWith(
          {String? id,
          String? postId,
          String? platform,
          String? status,
          String? method,
          Value<DateTime?> postedAt = const Value.absent(),
          Value<String?> externalPostId = const Value.absent(),
          Value<String?> externalPostUrl = const Value.absent(),
          Value<String?> errorMessage = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      PostingLogsTableData(
        id: id ?? this.id,
        postId: postId ?? this.postId,
        platform: platform ?? this.platform,
        status: status ?? this.status,
        method: method ?? this.method,
        postedAt: postedAt.present ? postedAt.value : this.postedAt,
        externalPostId:
            externalPostId.present ? externalPostId.value : this.externalPostId,
        externalPostUrl: externalPostUrl.present
            ? externalPostUrl.value
            : this.externalPostUrl,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  PostingLogsTableData copyWithCompanion(PostingLogsTableCompanion data) {
    return PostingLogsTableData(
      id: data.id.present ? data.id.value : this.id,
      postId: data.postId.present ? data.postId.value : this.postId,
      platform: data.platform.present ? data.platform.value : this.platform,
      status: data.status.present ? data.status.value : this.status,
      method: data.method.present ? data.method.value : this.method,
      postedAt: data.postedAt.present ? data.postedAt.value : this.postedAt,
      externalPostId: data.externalPostId.present
          ? data.externalPostId.value
          : this.externalPostId,
      externalPostUrl: data.externalPostUrl.present
          ? data.externalPostUrl.value
          : this.externalPostUrl,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PostingLogsTableData(')
          ..write('id: $id, ')
          ..write('postId: $postId, ')
          ..write('platform: $platform, ')
          ..write('status: $status, ')
          ..write('method: $method, ')
          ..write('postedAt: $postedAt, ')
          ..write('externalPostId: $externalPostId, ')
          ..write('externalPostUrl: $externalPostUrl, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      postId,
      platform,
      status,
      method,
      postedAt,
      externalPostId,
      externalPostUrl,
      errorMessage,
      notes,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostingLogsTableData &&
          other.id == this.id &&
          other.postId == this.postId &&
          other.platform == this.platform &&
          other.status == this.status &&
          other.method == this.method &&
          other.postedAt == this.postedAt &&
          other.externalPostId == this.externalPostId &&
          other.externalPostUrl == this.externalPostUrl &&
          other.errorMessage == this.errorMessage &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class PostingLogsTableCompanion extends UpdateCompanion<PostingLogsTableData> {
  final Value<String> id;
  final Value<String> postId;
  final Value<String> platform;
  final Value<String> status;
  final Value<String> method;
  final Value<DateTime?> postedAt;
  final Value<String?> externalPostId;
  final Value<String?> externalPostUrl;
  final Value<String?> errorMessage;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PostingLogsTableCompanion({
    this.id = const Value.absent(),
    this.postId = const Value.absent(),
    this.platform = const Value.absent(),
    this.status = const Value.absent(),
    this.method = const Value.absent(),
    this.postedAt = const Value.absent(),
    this.externalPostId = const Value.absent(),
    this.externalPostUrl = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostingLogsTableCompanion.insert({
    required String id,
    required String postId,
    required String platform,
    this.status = const Value.absent(),
    this.method = const Value.absent(),
    this.postedAt = const Value.absent(),
    this.externalPostId = const Value.absent(),
    this.externalPostUrl = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        postId = Value(postId),
        platform = Value(platform),
        createdAt = Value(createdAt);
  static Insertable<PostingLogsTableData> custom({
    Expression<String>? id,
    Expression<String>? postId,
    Expression<String>? platform,
    Expression<String>? status,
    Expression<String>? method,
    Expression<DateTime>? postedAt,
    Expression<String>? externalPostId,
    Expression<String>? externalPostUrl,
    Expression<String>? errorMessage,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (postId != null) 'post_id': postId,
      if (platform != null) 'platform': platform,
      if (status != null) 'status': status,
      if (method != null) 'method': method,
      if (postedAt != null) 'posted_at': postedAt,
      if (externalPostId != null) 'external_post_id': externalPostId,
      if (externalPostUrl != null) 'external_post_url': externalPostUrl,
      if (errorMessage != null) 'error_message': errorMessage,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostingLogsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? postId,
      Value<String>? platform,
      Value<String>? status,
      Value<String>? method,
      Value<DateTime?>? postedAt,
      Value<String?>? externalPostId,
      Value<String?>? externalPostUrl,
      Value<String?>? errorMessage,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PostingLogsTableCompanion(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      platform: platform ?? this.platform,
      status: status ?? this.status,
      method: method ?? this.method,
      postedAt: postedAt ?? this.postedAt,
      externalPostId: externalPostId ?? this.externalPostId,
      externalPostUrl: externalPostUrl ?? this.externalPostUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (postId.present) {
      map['post_id'] = Variable<String>(postId.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (postedAt.present) {
      map['posted_at'] = Variable<DateTime>(postedAt.value);
    }
    if (externalPostId.present) {
      map['external_post_id'] = Variable<String>(externalPostId.value);
    }
    if (externalPostUrl.present) {
      map['external_post_url'] = Variable<String>(externalPostUrl.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostingLogsTableCompanion(')
          ..write('id: $id, ')
          ..write('postId: $postId, ')
          ..write('platform: $platform, ')
          ..write('status: $status, ')
          ..write('method: $method, ')
          ..write('postedAt: $postedAt, ')
          ..write('externalPostId: $externalPostId, ')
          ..write('externalPostUrl: $externalPostUrl, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTableTable extends RemindersTable
    with TableInfo<$RemindersTableTable, RemindersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _postIdMeta = const VerificationMeta('postId');
  @override
  late final GeneratedColumn<String> postId = GeneratedColumn<String>(
      'post_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
      'scheduled_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _repeatMeta = const VerificationMeta('repeat');
  @override
  late final GeneratedColumn<String> repeat = GeneratedColumn<String>(
      'repeat', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('none'));
  static const VerificationMeta _repeatDaysJsonMeta =
      const VerificationMeta('repeatDaysJson');
  @override
  late final GeneratedColumn<String> repeatDaysJson = GeneratedColumn<String>(
      'repeat_days_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _isEnabledMeta =
      const VerificationMeta('isEnabled');
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
      'is_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _notificationIdMeta =
      const VerificationMeta('notificationId');
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
      'notification_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        postId,
        title,
        body,
        scheduledAt,
        repeat,
        repeatDaysJson,
        isEnabled,
        notificationId,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(Insertable<RemindersTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('post_id')) {
      context.handle(_postIdMeta,
          postId.isAcceptableOrUnknown(data['post_id']!, _postIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('repeat')) {
      context.handle(_repeatMeta,
          repeat.isAcceptableOrUnknown(data['repeat']!, _repeatMeta));
    }
    if (data.containsKey('repeat_days_json')) {
      context.handle(
          _repeatDaysJsonMeta,
          repeatDaysJson.isAcceptableOrUnknown(
              data['repeat_days_json']!, _repeatDaysJsonMeta));
    }
    if (data.containsKey('is_enabled')) {
      context.handle(_isEnabledMeta,
          isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta));
    }
    if (data.containsKey('notification_id')) {
      context.handle(
          _notificationIdMeta,
          notificationId.isAcceptableOrUnknown(
              data['notification_id']!, _notificationIdMeta));
    } else if (isInserting) {
      context.missing(_notificationIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RemindersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RemindersTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      postId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}post_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body']),
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scheduled_at'])!,
      repeat: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}repeat'])!,
      repeatDaysJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}repeat_days_json'])!,
      isEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_enabled'])!,
      notificationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}notification_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $RemindersTableTable createAlias(String alias) {
    return $RemindersTableTable(attachedDatabase, alias);
  }
}

class RemindersTableData extends DataClass
    implements Insertable<RemindersTableData> {
  final String id;
  final String? postId;
  final String title;
  final String? body;
  final DateTime scheduledAt;
  final String repeat;
  final String repeatDaysJson;
  final bool isEnabled;
  final int notificationId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RemindersTableData(
      {required this.id,
      this.postId,
      required this.title,
      this.body,
      required this.scheduledAt,
      required this.repeat,
      required this.repeatDaysJson,
      required this.isEnabled,
      required this.notificationId,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || postId != null) {
      map['post_id'] = Variable<String>(postId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    map['repeat'] = Variable<String>(repeat);
    map['repeat_days_json'] = Variable<String>(repeatDaysJson);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['notification_id'] = Variable<int>(notificationId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RemindersTableCompanion toCompanion(bool nullToAbsent) {
    return RemindersTableCompanion(
      id: Value(id),
      postId:
          postId == null && nullToAbsent ? const Value.absent() : Value(postId),
      title: Value(title),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      scheduledAt: Value(scheduledAt),
      repeat: Value(repeat),
      repeatDaysJson: Value(repeatDaysJson),
      isEnabled: Value(isEnabled),
      notificationId: Value(notificationId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RemindersTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RemindersTableData(
      id: serializer.fromJson<String>(json['id']),
      postId: serializer.fromJson<String?>(json['postId']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String?>(json['body']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      repeat: serializer.fromJson<String>(json['repeat']),
      repeatDaysJson: serializer.fromJson<String>(json['repeatDaysJson']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      notificationId: serializer.fromJson<int>(json['notificationId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'postId': serializer.toJson<String?>(postId),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String?>(body),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'repeat': serializer.toJson<String>(repeat),
      'repeatDaysJson': serializer.toJson<String>(repeatDaysJson),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'notificationId': serializer.toJson<int>(notificationId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RemindersTableData copyWith(
          {String? id,
          Value<String?> postId = const Value.absent(),
          String? title,
          Value<String?> body = const Value.absent(),
          DateTime? scheduledAt,
          String? repeat,
          String? repeatDaysJson,
          bool? isEnabled,
          int? notificationId,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      RemindersTableData(
        id: id ?? this.id,
        postId: postId.present ? postId.value : this.postId,
        title: title ?? this.title,
        body: body.present ? body.value : this.body,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        repeat: repeat ?? this.repeat,
        repeatDaysJson: repeatDaysJson ?? this.repeatDaysJson,
        isEnabled: isEnabled ?? this.isEnabled,
        notificationId: notificationId ?? this.notificationId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  RemindersTableData copyWithCompanion(RemindersTableCompanion data) {
    return RemindersTableData(
      id: data.id.present ? data.id.value : this.id,
      postId: data.postId.present ? data.postId.value : this.postId,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      repeat: data.repeat.present ? data.repeat.value : this.repeat,
      repeatDaysJson: data.repeatDaysJson.present
          ? data.repeatDaysJson.value
          : this.repeatDaysJson,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RemindersTableData(')
          ..write('id: $id, ')
          ..write('postId: $postId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('repeat: $repeat, ')
          ..write('repeatDaysJson: $repeatDaysJson, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('notificationId: $notificationId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, postId, title, body, scheduledAt, repeat,
      repeatDaysJson, isEnabled, notificationId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RemindersTableData &&
          other.id == this.id &&
          other.postId == this.postId &&
          other.title == this.title &&
          other.body == this.body &&
          other.scheduledAt == this.scheduledAt &&
          other.repeat == this.repeat &&
          other.repeatDaysJson == this.repeatDaysJson &&
          other.isEnabled == this.isEnabled &&
          other.notificationId == this.notificationId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RemindersTableCompanion extends UpdateCompanion<RemindersTableData> {
  final Value<String> id;
  final Value<String?> postId;
  final Value<String> title;
  final Value<String?> body;
  final Value<DateTime> scheduledAt;
  final Value<String> repeat;
  final Value<String> repeatDaysJson;
  final Value<bool> isEnabled;
  final Value<int> notificationId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RemindersTableCompanion({
    this.id = const Value.absent(),
    this.postId = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.repeat = const Value.absent(),
    this.repeatDaysJson = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersTableCompanion.insert({
    required String id,
    this.postId = const Value.absent(),
    required String title,
    this.body = const Value.absent(),
    required DateTime scheduledAt,
    this.repeat = const Value.absent(),
    this.repeatDaysJson = const Value.absent(),
    this.isEnabled = const Value.absent(),
    required int notificationId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        scheduledAt = Value(scheduledAt),
        notificationId = Value(notificationId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<RemindersTableData> custom({
    Expression<String>? id,
    Expression<String>? postId,
    Expression<String>? title,
    Expression<String>? body,
    Expression<DateTime>? scheduledAt,
    Expression<String>? repeat,
    Expression<String>? repeatDaysJson,
    Expression<bool>? isEnabled,
    Expression<int>? notificationId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (postId != null) 'post_id': postId,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (repeat != null) 'repeat': repeat,
      if (repeatDaysJson != null) 'repeat_days_json': repeatDaysJson,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (notificationId != null) 'notification_id': notificationId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersTableCompanion copyWith(
      {Value<String>? id,
      Value<String?>? postId,
      Value<String>? title,
      Value<String?>? body,
      Value<DateTime>? scheduledAt,
      Value<String>? repeat,
      Value<String>? repeatDaysJson,
      Value<bool>? isEnabled,
      Value<int>? notificationId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return RemindersTableCompanion(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      repeat: repeat ?? this.repeat,
      repeatDaysJson: repeatDaysJson ?? this.repeatDaysJson,
      isEnabled: isEnabled ?? this.isEnabled,
      notificationId: notificationId ?? this.notificationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (postId.present) {
      map['post_id'] = Variable<String>(postId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (repeat.present) {
      map['repeat'] = Variable<String>(repeat.value);
    }
    if (repeatDaysJson.present) {
      map['repeat_days_json'] = Variable<String>(repeatDaysJson.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersTableCompanion(')
          ..write('id: $id, ')
          ..write('postId: $postId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('repeat: $repeat, ')
          ..write('repeatDaysJson: $repeatDaysJson, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('notificationId: $notificationId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HashtagSuggestionsTableTable extends HashtagSuggestionsTable
    with TableInfo<$HashtagSuggestionsTableTable, HashtagSuggestionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HashtagSuggestionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
      'tag', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usageCountMeta =
      const VerificationMeta('usageCount');
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
      'usage_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastUsedAtMeta =
      const VerificationMeta('lastUsedAt');
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
      'last_used_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [tag, usageCount, lastUsedAt, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hashtag_suggestions';
  @override
  VerificationContext validateIntegrity(
      Insertable<HashtagSuggestionsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tag')) {
      context.handle(
          _tagMeta, tag.isAcceptableOrUnknown(data['tag']!, _tagMeta));
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    if (data.containsKey('usage_count')) {
      context.handle(
          _usageCountMeta,
          usageCount.isAcceptableOrUnknown(
              data['usage_count']!, _usageCountMeta));
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
          _lastUsedAtMeta,
          lastUsedAt.isAcceptableOrUnknown(
              data['last_used_at']!, _lastUsedAtMeta));
    } else if (isInserting) {
      context.missing(_lastUsedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tag};
  @override
  HashtagSuggestionsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HashtagSuggestionsTableData(
      tag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag'])!,
      usageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}usage_count'])!,
      lastUsedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_used_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $HashtagSuggestionsTableTable createAlias(String alias) {
    return $HashtagSuggestionsTableTable(attachedDatabase, alias);
  }
}

class HashtagSuggestionsTableData extends DataClass
    implements Insertable<HashtagSuggestionsTableData> {
  final String tag;
  final int usageCount;
  final DateTime lastUsedAt;
  final DateTime createdAt;
  const HashtagSuggestionsTableData(
      {required this.tag,
      required this.usageCount,
      required this.lastUsedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tag'] = Variable<String>(tag);
    map['usage_count'] = Variable<int>(usageCount);
    map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HashtagSuggestionsTableCompanion toCompanion(bool nullToAbsent) {
    return HashtagSuggestionsTableCompanion(
      tag: Value(tag),
      usageCount: Value(usageCount),
      lastUsedAt: Value(lastUsedAt),
      createdAt: Value(createdAt),
    );
  }

  factory HashtagSuggestionsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HashtagSuggestionsTableData(
      tag: serializer.fromJson<String>(json['tag']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      lastUsedAt: serializer.fromJson<DateTime>(json['lastUsedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tag': serializer.toJson<String>(tag),
      'usageCount': serializer.toJson<int>(usageCount),
      'lastUsedAt': serializer.toJson<DateTime>(lastUsedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HashtagSuggestionsTableData copyWith(
          {String? tag,
          int? usageCount,
          DateTime? lastUsedAt,
          DateTime? createdAt}) =>
      HashtagSuggestionsTableData(
        tag: tag ?? this.tag,
        usageCount: usageCount ?? this.usageCount,
        lastUsedAt: lastUsedAt ?? this.lastUsedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  HashtagSuggestionsTableData copyWithCompanion(
      HashtagSuggestionsTableCompanion data) {
    return HashtagSuggestionsTableData(
      tag: data.tag.present ? data.tag.value : this.tag,
      usageCount:
          data.usageCount.present ? data.usageCount.value : this.usageCount,
      lastUsedAt:
          data.lastUsedAt.present ? data.lastUsedAt.value : this.lastUsedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HashtagSuggestionsTableData(')
          ..write('tag: $tag, ')
          ..write('usageCount: $usageCount, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tag, usageCount, lastUsedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HashtagSuggestionsTableData &&
          other.tag == this.tag &&
          other.usageCount == this.usageCount &&
          other.lastUsedAt == this.lastUsedAt &&
          other.createdAt == this.createdAt);
}

class HashtagSuggestionsTableCompanion
    extends UpdateCompanion<HashtagSuggestionsTableData> {
  final Value<String> tag;
  final Value<int> usageCount;
  final Value<DateTime> lastUsedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const HashtagSuggestionsTableCompanion({
    this.tag = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HashtagSuggestionsTableCompanion.insert({
    required String tag,
    this.usageCount = const Value.absent(),
    required DateTime lastUsedAt,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : tag = Value(tag),
        lastUsedAt = Value(lastUsedAt),
        createdAt = Value(createdAt);
  static Insertable<HashtagSuggestionsTableData> custom({
    Expression<String>? tag,
    Expression<int>? usageCount,
    Expression<DateTime>? lastUsedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tag != null) 'tag': tag,
      if (usageCount != null) 'usage_count': usageCount,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HashtagSuggestionsTableCompanion copyWith(
      {Value<String>? tag,
      Value<int>? usageCount,
      Value<DateTime>? lastUsedAt,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return HashtagSuggestionsTableCompanion(
      tag: tag ?? this.tag,
      usageCount: usageCount ?? this.usageCount,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HashtagSuggestionsTableCompanion(')
          ..write('tag: $tag, ')
          ..write('usageCount: $usageCount, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CommentCategoriesTableTable commentCategoriesTable =
      $CommentCategoriesTableTable(this);
  late final $CommentsTableTable commentsTable = $CommentsTableTable(this);
  late final $SocialPostsTableTable socialPostsTable =
      $SocialPostsTableTable(this);
  late final $SocialPostPlatformsTableTable socialPostPlatformsTable =
      $SocialPostPlatformsTableTable(this);
  late final $PostingLogsTableTable postingLogsTable =
      $PostingLogsTableTable(this);
  late final $RemindersTableTable remindersTable = $RemindersTableTable(this);
  late final $HashtagSuggestionsTableTable hashtagSuggestionsTable =
      $HashtagSuggestionsTableTable(this);
  late final CommentDao commentDao = CommentDao(this as AppDatabase);
  late final PostDao postDao = PostDao(this as AppDatabase);
  late final LogDao logDao = LogDao(this as AppDatabase);
  late final ReminderDao reminderDao = ReminderDao(this as AppDatabase);
  late final HashtagDao hashtagDao = HashtagDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        commentCategoriesTable,
        commentsTable,
        socialPostsTable,
        socialPostPlatformsTable,
        postingLogsTable,
        remindersTable,
        hashtagSuggestionsTable
      ];
}

typedef $$CommentCategoriesTableTableCreateCompanionBuilder
    = CommentCategoriesTableCompanion Function({
  required String id,
  required String name,
  required String icon,
  required String colorHex,
  Value<bool> isPredefined,
  Value<int> sortOrder,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CommentCategoriesTableTableUpdateCompanionBuilder
    = CommentCategoriesTableCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> icon,
  Value<String> colorHex,
  Value<bool> isPredefined,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CommentCategoriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CommentCategoriesTableTable> {
  $$CommentCategoriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPredefined => $composableBuilder(
      column: $table.isPredefined, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CommentCategoriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CommentCategoriesTableTable> {
  $$CommentCategoriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPredefined => $composableBuilder(
      column: $table.isPredefined,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CommentCategoriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommentCategoriesTableTable> {
  $$CommentCategoriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<bool> get isPredefined => $composableBuilder(
      column: $table.isPredefined, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CommentCategoriesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CommentCategoriesTableTable,
    CommentCategoriesTableData,
    $$CommentCategoriesTableTableFilterComposer,
    $$CommentCategoriesTableTableOrderingComposer,
    $$CommentCategoriesTableTableAnnotationComposer,
    $$CommentCategoriesTableTableCreateCompanionBuilder,
    $$CommentCategoriesTableTableUpdateCompanionBuilder,
    (
      CommentCategoriesTableData,
      BaseReferences<_$AppDatabase, $CommentCategoriesTableTable,
          CommentCategoriesTableData>
    ),
    CommentCategoriesTableData,
    PrefetchHooks Function()> {
  $$CommentCategoriesTableTableTableManager(
      _$AppDatabase db, $CommentCategoriesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommentCategoriesTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CommentCategoriesTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommentCategoriesTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<String> colorHex = const Value.absent(),
            Value<bool> isPredefined = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CommentCategoriesTableCompanion(
            id: id,
            name: name,
            icon: icon,
            colorHex: colorHex,
            isPredefined: isPredefined,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String icon,
            required String colorHex,
            Value<bool> isPredefined = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CommentCategoriesTableCompanion.insert(
            id: id,
            name: name,
            icon: icon,
            colorHex: colorHex,
            isPredefined: isPredefined,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CommentCategoriesTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $CommentCategoriesTableTable,
        CommentCategoriesTableData,
        $$CommentCategoriesTableTableFilterComposer,
        $$CommentCategoriesTableTableOrderingComposer,
        $$CommentCategoriesTableTableAnnotationComposer,
        $$CommentCategoriesTableTableCreateCompanionBuilder,
        $$CommentCategoriesTableTableUpdateCompanionBuilder,
        (
          CommentCategoriesTableData,
          BaseReferences<_$AppDatabase, $CommentCategoriesTableTable,
              CommentCategoriesTableData>
        ),
        CommentCategoriesTableData,
        PrefetchHooks Function()>;
typedef $$CommentsTableTableCreateCompanionBuilder = CommentsTableCompanion
    Function({
  required String id,
  required String categoryId,
  required String commentText,
  Value<String> tagsJson,
  Value<bool> isFavorite,
  Value<int> usageCount,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CommentsTableTableUpdateCompanionBuilder = CommentsTableCompanion
    Function({
  Value<String> id,
  Value<String> categoryId,
  Value<String> commentText,
  Value<String> tagsJson,
  Value<bool> isFavorite,
  Value<int> usageCount,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CommentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CommentsTableTable> {
  $$CommentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get commentText => $composableBuilder(
      column: $table.commentText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CommentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CommentsTableTable> {
  $$CommentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get commentText => $composableBuilder(
      column: $table.commentText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CommentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommentsTableTable> {
  $$CommentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get commentText => $composableBuilder(
      column: $table.commentText, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CommentsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CommentsTableTable,
    CommentsTableData,
    $$CommentsTableTableFilterComposer,
    $$CommentsTableTableOrderingComposer,
    $$CommentsTableTableAnnotationComposer,
    $$CommentsTableTableCreateCompanionBuilder,
    $$CommentsTableTableUpdateCompanionBuilder,
    (
      CommentsTableData,
      BaseReferences<_$AppDatabase, $CommentsTableTable, CommentsTableData>
    ),
    CommentsTableData,
    PrefetchHooks Function()> {
  $$CommentsTableTableTableManager(_$AppDatabase db, $CommentsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<String> commentText = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<int> usageCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CommentsTableCompanion(
            id: id,
            categoryId: categoryId,
            commentText: commentText,
            tagsJson: tagsJson,
            isFavorite: isFavorite,
            usageCount: usageCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String categoryId,
            required String commentText,
            Value<String> tagsJson = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<int> usageCount = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CommentsTableCompanion.insert(
            id: id,
            categoryId: categoryId,
            commentText: commentText,
            tagsJson: tagsJson,
            isFavorite: isFavorite,
            usageCount: usageCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CommentsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CommentsTableTable,
    CommentsTableData,
    $$CommentsTableTableFilterComposer,
    $$CommentsTableTableOrderingComposer,
    $$CommentsTableTableAnnotationComposer,
    $$CommentsTableTableCreateCompanionBuilder,
    $$CommentsTableTableUpdateCompanionBuilder,
    (
      CommentsTableData,
      BaseReferences<_$AppDatabase, $CommentsTableTable, CommentsTableData>
    ),
    CommentsTableData,
    PrefetchHooks Function()>;
typedef $$SocialPostsTableTableCreateCompanionBuilder
    = SocialPostsTableCompanion Function({
  required String id,
  required String title,
  required String content,
  Value<String> status,
  Value<DateTime?> scheduledAt,
  Value<bool> isRecurring,
  Value<String> recurringType,
  Value<String> recurringDaysJson,
  Value<String> attachmentsJson,
  Value<String> tagsJson,
  Value<String?> notes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$SocialPostsTableTableUpdateCompanionBuilder
    = SocialPostsTableCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> content,
  Value<String> status,
  Value<DateTime?> scheduledAt,
  Value<bool> isRecurring,
  Value<String> recurringType,
  Value<String> recurringDaysJson,
  Value<String> attachmentsJson,
  Value<String> tagsJson,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SocialPostsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SocialPostsTableTable> {
  $$SocialPostsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurringType => $composableBuilder(
      column: $table.recurringType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurringDaysJson => $composableBuilder(
      column: $table.recurringDaysJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get attachmentsJson => $composableBuilder(
      column: $table.attachmentsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SocialPostsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SocialPostsTableTable> {
  $$SocialPostsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurringType => $composableBuilder(
      column: $table.recurringType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurringDaysJson => $composableBuilder(
      column: $table.recurringDaysJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get attachmentsJson => $composableBuilder(
      column: $table.attachmentsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SocialPostsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SocialPostsTableTable> {
  $$SocialPostsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => column);

  GeneratedColumn<String> get recurringType => $composableBuilder(
      column: $table.recurringType, builder: (column) => column);

  GeneratedColumn<String> get recurringDaysJson => $composableBuilder(
      column: $table.recurringDaysJson, builder: (column) => column);

  GeneratedColumn<String> get attachmentsJson => $composableBuilder(
      column: $table.attachmentsJson, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SocialPostsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SocialPostsTableTable,
    SocialPostsTableData,
    $$SocialPostsTableTableFilterComposer,
    $$SocialPostsTableTableOrderingComposer,
    $$SocialPostsTableTableAnnotationComposer,
    $$SocialPostsTableTableCreateCompanionBuilder,
    $$SocialPostsTableTableUpdateCompanionBuilder,
    (
      SocialPostsTableData,
      BaseReferences<_$AppDatabase, $SocialPostsTableTable,
          SocialPostsTableData>
    ),
    SocialPostsTableData,
    PrefetchHooks Function()> {
  $$SocialPostsTableTableTableManager(
      _$AppDatabase db, $SocialPostsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SocialPostsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SocialPostsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SocialPostsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> scheduledAt = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String> recurringType = const Value.absent(),
            Value<String> recurringDaysJson = const Value.absent(),
            Value<String> attachmentsJson = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SocialPostsTableCompanion(
            id: id,
            title: title,
            content: content,
            status: status,
            scheduledAt: scheduledAt,
            isRecurring: isRecurring,
            recurringType: recurringType,
            recurringDaysJson: recurringDaysJson,
            attachmentsJson: attachmentsJson,
            tagsJson: tagsJson,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String content,
            Value<String> status = const Value.absent(),
            Value<DateTime?> scheduledAt = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String> recurringType = const Value.absent(),
            Value<String> recurringDaysJson = const Value.absent(),
            Value<String> attachmentsJson = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SocialPostsTableCompanion.insert(
            id: id,
            title: title,
            content: content,
            status: status,
            scheduledAt: scheduledAt,
            isRecurring: isRecurring,
            recurringType: recurringType,
            recurringDaysJson: recurringDaysJson,
            attachmentsJson: attachmentsJson,
            tagsJson: tagsJson,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SocialPostsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SocialPostsTableTable,
    SocialPostsTableData,
    $$SocialPostsTableTableFilterComposer,
    $$SocialPostsTableTableOrderingComposer,
    $$SocialPostsTableTableAnnotationComposer,
    $$SocialPostsTableTableCreateCompanionBuilder,
    $$SocialPostsTableTableUpdateCompanionBuilder,
    (
      SocialPostsTableData,
      BaseReferences<_$AppDatabase, $SocialPostsTableTable,
          SocialPostsTableData>
    ),
    SocialPostsTableData,
    PrefetchHooks Function()>;
typedef $$SocialPostPlatformsTableTableCreateCompanionBuilder
    = SocialPostPlatformsTableCompanion Function({
  Value<int> id,
  required String postId,
  required String platform,
});
typedef $$SocialPostPlatformsTableTableUpdateCompanionBuilder
    = SocialPostPlatformsTableCompanion Function({
  Value<int> id,
  Value<String> postId,
  Value<String> platform,
});

class $$SocialPostPlatformsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SocialPostPlatformsTableTable> {
  $$SocialPostPlatformsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get postId => $composableBuilder(
      column: $table.postId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnFilters(column));
}

class $$SocialPostPlatformsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SocialPostPlatformsTableTable> {
  $$SocialPostPlatformsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get postId => $composableBuilder(
      column: $table.postId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnOrderings(column));
}

class $$SocialPostPlatformsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SocialPostPlatformsTableTable> {
  $$SocialPostPlatformsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get postId =>
      $composableBuilder(column: $table.postId, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);
}

class $$SocialPostPlatformsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SocialPostPlatformsTableTable,
    SocialPostPlatformsTableData,
    $$SocialPostPlatformsTableTableFilterComposer,
    $$SocialPostPlatformsTableTableOrderingComposer,
    $$SocialPostPlatformsTableTableAnnotationComposer,
    $$SocialPostPlatformsTableTableCreateCompanionBuilder,
    $$SocialPostPlatformsTableTableUpdateCompanionBuilder,
    (
      SocialPostPlatformsTableData,
      BaseReferences<_$AppDatabase, $SocialPostPlatformsTableTable,
          SocialPostPlatformsTableData>
    ),
    SocialPostPlatformsTableData,
    PrefetchHooks Function()> {
  $$SocialPostPlatformsTableTableTableManager(
      _$AppDatabase db, $SocialPostPlatformsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SocialPostPlatformsTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$SocialPostPlatformsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SocialPostPlatformsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> postId = const Value.absent(),
            Value<String> platform = const Value.absent(),
          }) =>
              SocialPostPlatformsTableCompanion(
            id: id,
            postId: postId,
            platform: platform,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String postId,
            required String platform,
          }) =>
              SocialPostPlatformsTableCompanion.insert(
            id: id,
            postId: postId,
            platform: platform,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SocialPostPlatformsTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $SocialPostPlatformsTableTable,
        SocialPostPlatformsTableData,
        $$SocialPostPlatformsTableTableFilterComposer,
        $$SocialPostPlatformsTableTableOrderingComposer,
        $$SocialPostPlatformsTableTableAnnotationComposer,
        $$SocialPostPlatformsTableTableCreateCompanionBuilder,
        $$SocialPostPlatformsTableTableUpdateCompanionBuilder,
        (
          SocialPostPlatformsTableData,
          BaseReferences<_$AppDatabase, $SocialPostPlatformsTableTable,
              SocialPostPlatformsTableData>
        ),
        SocialPostPlatformsTableData,
        PrefetchHooks Function()>;
typedef $$PostingLogsTableTableCreateCompanionBuilder
    = PostingLogsTableCompanion Function({
  required String id,
  required String postId,
  required String platform,
  Value<String> status,
  Value<String> method,
  Value<DateTime?> postedAt,
  Value<String?> externalPostId,
  Value<String?> externalPostUrl,
  Value<String?> errorMessage,
  Value<String?> notes,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PostingLogsTableTableUpdateCompanionBuilder
    = PostingLogsTableCompanion Function({
  Value<String> id,
  Value<String> postId,
  Value<String> platform,
  Value<String> status,
  Value<String> method,
  Value<DateTime?> postedAt,
  Value<String?> externalPostId,
  Value<String?> externalPostUrl,
  Value<String?> errorMessage,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PostingLogsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PostingLogsTableTable> {
  $$PostingLogsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get postId => $composableBuilder(
      column: $table.postId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get postedAt => $composableBuilder(
      column: $table.postedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalPostId => $composableBuilder(
      column: $table.externalPostId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalPostUrl => $composableBuilder(
      column: $table.externalPostUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PostingLogsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PostingLogsTableTable> {
  $$PostingLogsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get postId => $composableBuilder(
      column: $table.postId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get postedAt => $composableBuilder(
      column: $table.postedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalPostId => $composableBuilder(
      column: $table.externalPostId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalPostUrl => $composableBuilder(
      column: $table.externalPostUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PostingLogsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PostingLogsTableTable> {
  $$PostingLogsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get postId =>
      $composableBuilder(column: $table.postId, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<DateTime> get postedAt =>
      $composableBuilder(column: $table.postedAt, builder: (column) => column);

  GeneratedColumn<String> get externalPostId => $composableBuilder(
      column: $table.externalPostId, builder: (column) => column);

  GeneratedColumn<String> get externalPostUrl => $composableBuilder(
      column: $table.externalPostUrl, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PostingLogsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PostingLogsTableTable,
    PostingLogsTableData,
    $$PostingLogsTableTableFilterComposer,
    $$PostingLogsTableTableOrderingComposer,
    $$PostingLogsTableTableAnnotationComposer,
    $$PostingLogsTableTableCreateCompanionBuilder,
    $$PostingLogsTableTableUpdateCompanionBuilder,
    (
      PostingLogsTableData,
      BaseReferences<_$AppDatabase, $PostingLogsTableTable,
          PostingLogsTableData>
    ),
    PostingLogsTableData,
    PrefetchHooks Function()> {
  $$PostingLogsTableTableTableManager(
      _$AppDatabase db, $PostingLogsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostingLogsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostingLogsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostingLogsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> postId = const Value.absent(),
            Value<String> platform = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> method = const Value.absent(),
            Value<DateTime?> postedAt = const Value.absent(),
            Value<String?> externalPostId = const Value.absent(),
            Value<String?> externalPostUrl = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PostingLogsTableCompanion(
            id: id,
            postId: postId,
            platform: platform,
            status: status,
            method: method,
            postedAt: postedAt,
            externalPostId: externalPostId,
            externalPostUrl: externalPostUrl,
            errorMessage: errorMessage,
            notes: notes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String postId,
            required String platform,
            Value<String> status = const Value.absent(),
            Value<String> method = const Value.absent(),
            Value<DateTime?> postedAt = const Value.absent(),
            Value<String?> externalPostId = const Value.absent(),
            Value<String?> externalPostUrl = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PostingLogsTableCompanion.insert(
            id: id,
            postId: postId,
            platform: platform,
            status: status,
            method: method,
            postedAt: postedAt,
            externalPostId: externalPostId,
            externalPostUrl: externalPostUrl,
            errorMessage: errorMessage,
            notes: notes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PostingLogsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PostingLogsTableTable,
    PostingLogsTableData,
    $$PostingLogsTableTableFilterComposer,
    $$PostingLogsTableTableOrderingComposer,
    $$PostingLogsTableTableAnnotationComposer,
    $$PostingLogsTableTableCreateCompanionBuilder,
    $$PostingLogsTableTableUpdateCompanionBuilder,
    (
      PostingLogsTableData,
      BaseReferences<_$AppDatabase, $PostingLogsTableTable,
          PostingLogsTableData>
    ),
    PostingLogsTableData,
    PrefetchHooks Function()>;
typedef $$RemindersTableTableCreateCompanionBuilder = RemindersTableCompanion
    Function({
  required String id,
  Value<String?> postId,
  required String title,
  Value<String?> body,
  required DateTime scheduledAt,
  Value<String> repeat,
  Value<String> repeatDaysJson,
  Value<bool> isEnabled,
  required int notificationId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$RemindersTableTableUpdateCompanionBuilder = RemindersTableCompanion
    Function({
  Value<String> id,
  Value<String?> postId,
  Value<String> title,
  Value<String?> body,
  Value<DateTime> scheduledAt,
  Value<String> repeat,
  Value<String> repeatDaysJson,
  Value<bool> isEnabled,
  Value<int> notificationId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$RemindersTableTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTableTable> {
  $$RemindersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get postId => $composableBuilder(
      column: $table.postId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get repeat => $composableBuilder(
      column: $table.repeat, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get repeatDaysJson => $composableBuilder(
      column: $table.repeatDaysJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get notificationId => $composableBuilder(
      column: $table.notificationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$RemindersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTableTable> {
  $$RemindersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get postId => $composableBuilder(
      column: $table.postId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repeat => $composableBuilder(
      column: $table.repeat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repeatDaysJson => $composableBuilder(
      column: $table.repeatDaysJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get notificationId => $composableBuilder(
      column: $table.notificationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$RemindersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTableTable> {
  $$RemindersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get postId =>
      $composableBuilder(column: $table.postId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);

  GeneratedColumn<String> get repeat =>
      $composableBuilder(column: $table.repeat, builder: (column) => column);

  GeneratedColumn<String> get repeatDaysJson => $composableBuilder(
      column: $table.repeatDaysJson, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<int> get notificationId => $composableBuilder(
      column: $table.notificationId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RemindersTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RemindersTableTable,
    RemindersTableData,
    $$RemindersTableTableFilterComposer,
    $$RemindersTableTableOrderingComposer,
    $$RemindersTableTableAnnotationComposer,
    $$RemindersTableTableCreateCompanionBuilder,
    $$RemindersTableTableUpdateCompanionBuilder,
    (
      RemindersTableData,
      BaseReferences<_$AppDatabase, $RemindersTableTable, RemindersTableData>
    ),
    RemindersTableData,
    PrefetchHooks Function()> {
  $$RemindersTableTableTableManager(
      _$AppDatabase db, $RemindersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> postId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> body = const Value.absent(),
            Value<DateTime> scheduledAt = const Value.absent(),
            Value<String> repeat = const Value.absent(),
            Value<String> repeatDaysJson = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<int> notificationId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemindersTableCompanion(
            id: id,
            postId: postId,
            title: title,
            body: body,
            scheduledAt: scheduledAt,
            repeat: repeat,
            repeatDaysJson: repeatDaysJson,
            isEnabled: isEnabled,
            notificationId: notificationId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> postId = const Value.absent(),
            required String title,
            Value<String?> body = const Value.absent(),
            required DateTime scheduledAt,
            Value<String> repeat = const Value.absent(),
            Value<String> repeatDaysJson = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            required int notificationId,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              RemindersTableCompanion.insert(
            id: id,
            postId: postId,
            title: title,
            body: body,
            scheduledAt: scheduledAt,
            repeat: repeat,
            repeatDaysJson: repeatDaysJson,
            isEnabled: isEnabled,
            notificationId: notificationId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RemindersTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RemindersTableTable,
    RemindersTableData,
    $$RemindersTableTableFilterComposer,
    $$RemindersTableTableOrderingComposer,
    $$RemindersTableTableAnnotationComposer,
    $$RemindersTableTableCreateCompanionBuilder,
    $$RemindersTableTableUpdateCompanionBuilder,
    (
      RemindersTableData,
      BaseReferences<_$AppDatabase, $RemindersTableTable, RemindersTableData>
    ),
    RemindersTableData,
    PrefetchHooks Function()>;
typedef $$HashtagSuggestionsTableTableCreateCompanionBuilder
    = HashtagSuggestionsTableCompanion Function({
  required String tag,
  Value<int> usageCount,
  required DateTime lastUsedAt,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$HashtagSuggestionsTableTableUpdateCompanionBuilder
    = HashtagSuggestionsTableCompanion Function({
  Value<String> tag,
  Value<int> usageCount,
  Value<DateTime> lastUsedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$HashtagSuggestionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $HashtagSuggestionsTableTable> {
  $$HashtagSuggestionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tag => $composableBuilder(
      column: $table.tag, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$HashtagSuggestionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HashtagSuggestionsTableTable> {
  $$HashtagSuggestionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tag => $composableBuilder(
      column: $table.tag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$HashtagSuggestionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HashtagSuggestionsTableTable> {
  $$HashtagSuggestionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HashtagSuggestionsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HashtagSuggestionsTableTable,
    HashtagSuggestionsTableData,
    $$HashtagSuggestionsTableTableFilterComposer,
    $$HashtagSuggestionsTableTableOrderingComposer,
    $$HashtagSuggestionsTableTableAnnotationComposer,
    $$HashtagSuggestionsTableTableCreateCompanionBuilder,
    $$HashtagSuggestionsTableTableUpdateCompanionBuilder,
    (
      HashtagSuggestionsTableData,
      BaseReferences<_$AppDatabase, $HashtagSuggestionsTableTable,
          HashtagSuggestionsTableData>
    ),
    HashtagSuggestionsTableData,
    PrefetchHooks Function()> {
  $$HashtagSuggestionsTableTableTableManager(
      _$AppDatabase db, $HashtagSuggestionsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HashtagSuggestionsTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$HashtagSuggestionsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HashtagSuggestionsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> tag = const Value.absent(),
            Value<int> usageCount = const Value.absent(),
            Value<DateTime> lastUsedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HashtagSuggestionsTableCompanion(
            tag: tag,
            usageCount: usageCount,
            lastUsedAt: lastUsedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String tag,
            Value<int> usageCount = const Value.absent(),
            required DateTime lastUsedAt,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              HashtagSuggestionsTableCompanion.insert(
            tag: tag,
            usageCount: usageCount,
            lastUsedAt: lastUsedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HashtagSuggestionsTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $HashtagSuggestionsTableTable,
        HashtagSuggestionsTableData,
        $$HashtagSuggestionsTableTableFilterComposer,
        $$HashtagSuggestionsTableTableOrderingComposer,
        $$HashtagSuggestionsTableTableAnnotationComposer,
        $$HashtagSuggestionsTableTableCreateCompanionBuilder,
        $$HashtagSuggestionsTableTableUpdateCompanionBuilder,
        (
          HashtagSuggestionsTableData,
          BaseReferences<_$AppDatabase, $HashtagSuggestionsTableTable,
              HashtagSuggestionsTableData>
        ),
        HashtagSuggestionsTableData,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CommentCategoriesTableTableTableManager get commentCategoriesTable =>
      $$CommentCategoriesTableTableTableManager(
          _db, _db.commentCategoriesTable);
  $$CommentsTableTableTableManager get commentsTable =>
      $$CommentsTableTableTableManager(_db, _db.commentsTable);
  $$SocialPostsTableTableTableManager get socialPostsTable =>
      $$SocialPostsTableTableTableManager(_db, _db.socialPostsTable);
  $$SocialPostPlatformsTableTableTableManager get socialPostPlatformsTable =>
      $$SocialPostPlatformsTableTableTableManager(
          _db, _db.socialPostPlatformsTable);
  $$PostingLogsTableTableTableManager get postingLogsTable =>
      $$PostingLogsTableTableTableManager(_db, _db.postingLogsTable);
  $$RemindersTableTableTableManager get remindersTable =>
      $$RemindersTableTableTableManager(_db, _db.remindersTable);
  $$HashtagSuggestionsTableTableTableManager get hashtagSuggestionsTable =>
      $$HashtagSuggestionsTableTableTableManager(
          _db, _db.hashtagSuggestionsTable);
}
