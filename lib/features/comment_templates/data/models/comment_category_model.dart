import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/comment_category.dart';

extension CommentCategoryDataX on CommentCategoryRow {
  CommentCategory toDomain() => CommentCategory(
        id: id,
        name: name,
        icon: icon,
        colorHex: colorHex,
        isPredefined: isPredefined,
        sortOrder: sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension CommentCategoryX on CommentCategory {
  CommentCategoriesTableCompanion toCompanion() =>
      CommentCategoriesTableCompanion.insert(
        id: id,
        name: name,
        icon: icon,
        colorHex: colorHex,
        isPredefined: Value(isPredefined),
        sortOrder: Value(sortOrder),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
