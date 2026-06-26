import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/comment_category.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_local_datasource.dart';
import '../models/comment_category_model.dart';
import '../models/comment_model.dart';

const _uuid = Uuid();

class CommentRepositoryImpl implements CommentRepository {
  CommentRepositoryImpl(this._local);
  final CommentLocalDataSource _local;

  // Categories --------------------------------------------------------------

  @override
  Stream<List<CommentCategory>> watchCategories() {
    return _local.watchCategories().map(
          (rows) => rows.map((r) => r.toDomain()).toList(),
        );
  }

  @override
  Future<Either<Failure, List<CommentCategory>>> getAllCategories() async {
    try {
      final rows = await _local.getAllCategories();
      return Right(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentCategory>> createCategory({
    required String name,
    required String icon,
    required String colorHex,
  }) async {
    try {
      final now = DateTime.now();
      final entity = CommentCategory(
        id: _uuid.v4(),
        name: name,
        icon: icon,
        colorHex: colorHex,
        isPredefined: false,
        sortOrder: 1000 + now.millisecondsSinceEpoch.remainder(1000),
        createdAt: now,
        updatedAt: now,
      );
      await _local.insertCategory(entity.toCompanion());
      return Right(entity);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentCategory>> updateCategory(
      CommentCategory category) async {
    try {
      final updated = CommentCategory(
        id: category.id,
        name: category.name,
        icon: category.icon,
        colorHex: category.colorHex,
        isPredefined: category.isPredefined,
        sortOrder: category.sortOrder,
        createdAt: category.createdAt,
        updatedAt: DateTime.now(),
      );
      await _local.updateCategory(updated.toCompanion());
      return Right(updated);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(String id) async {
    try {
      final existing = await _local.getCategoryById(id);
      if (existing == null) {
        return const Left(NotFoundFailure(message: 'Category not found.'));
      }
      if (existing.isPredefined) {
        return const Left(PredefinedItemFailure(
          message: 'Predefined categories cannot be deleted.',
        ));
      }
      await _local.deleteCommentsByCategory(id);
      await _local.deleteCategory(id);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  // Comments --------------------------------------------------------------

  @override
  Stream<List<Comment>> watchCommentsByCategory(String categoryId) {
    return _local.watchByCategory(categoryId).map(
          (rows) => rows.map((r) => r.toDomain()).toList(),
        );
  }

  @override
  Stream<List<Comment>> watchAllComments() {
    return _local.watchAllComments().map(
          (rows) => rows.map((r) => r.toDomain()).toList(),
        );
  }

  @override
  Future<Either<Failure, List<Comment>>> getCommentsByCategory(
      String categoryId) async {
    try {
      final rows = await _local.getByCategory(categoryId);
      return Right(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Comment>>> searchComments(
      String query) async {
    try {
      if (query.trim().isEmpty) {
        return const Right([]);
      }
      final rows = await _local.searchComments(query);
      return Right(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Comment>> createComment({
    required String categoryId,
    required String text,
    List<String> tags = const [],
  }) async {
    try {
      final now = DateTime.now();
      final entity = Comment(
        id: _uuid.v4(),
        categoryId: categoryId,
        text: text,
        tags: tags,
        isFavorite: false,
        usageCount: 0,
        createdAt: now,
        updatedAt: now,
      );
      await _local.insertComment(entity.toCompanion());
      return Right(entity);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Comment>> updateComment(Comment comment) async {
    try {
      final updated = Comment(
        id: comment.id,
        categoryId: comment.categoryId,
        text: comment.text,
        tags: comment.tags,
        isFavorite: comment.isFavorite,
        usageCount: comment.usageCount,
        createdAt: comment.createdAt,
        updatedAt: DateTime.now(),
      );
      await _local.updateComment(updated.toCompanion());
      return Right(updated);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteComment(String id) async {
    try {
      await _local.deleteComment(id);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Comment>> toggleFavorite(String commentId) async {
    try {
      await _local.toggleFavorite(commentId);
      final updated = await _local.getCommentById(commentId);
      if (updated == null) {
        return const Left(NotFoundFailure(message: 'Comment not found.'));
      }
      return Right(updated.toDomain());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> incrementUsageCount(String commentId) async {
    try {
      await _local.incrementUsageCount(commentId);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
