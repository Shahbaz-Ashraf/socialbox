import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/comment_category.dart';

extension CommentDataX on CommentRow {
  Comment toDomain() => Comment(
        id: id,
        categoryId: categoryId,
        text: commentText,
        tags: StringListJson.fromJsonString(tagsJson),
        isFavorite: isFavorite,
        usageCount: usageCount,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension CommentX on Comment {
  CommentsTableCompanion toCompanion() => CommentsTableCompanion.insert(
        id: id,
        categoryId: categoryId,
        commentText: text,
        tagsJson: Value(tags.toJsonString()),
        isFavorite: Value(isFavorite),
        usageCount: Value(usageCount),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
