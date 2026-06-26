import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/comment_category.dart';

abstract class CommentRepository {
  Stream<List<CommentCategory>> watchCategories();
  Stream<List<Comment>> watchCommentsByCategory(String categoryId);
  Stream<List<Comment>> watchAllComments();

  Future<Either<Failure, List<CommentCategory>>> getAllCategories();
  Future<Either<Failure, CommentCategory>> createCategory({
    required String name,
    required String icon,
    required String colorHex,
  });
  Future<Either<Failure, CommentCategory>> updateCategory(
      CommentCategory category);
  Future<Either<Failure, Unit>> deleteCategory(String id);

  Future<Either<Failure, List<Comment>>> getCommentsByCategory(
      String categoryId);
  Future<Either<Failure, List<Comment>>> searchComments(String query);
  Future<Either<Failure, Comment>> createComment({
    required String categoryId,
    required String text,
    List<String> tags,
  });
  Future<Either<Failure, Comment>> updateComment(Comment comment);
  Future<Either<Failure, Unit>> deleteComment(String id);
  Future<Either<Failure, Comment>> toggleFavorite(String commentId);
  Future<Either<Failure, Unit>> incrementUsageCount(String commentId);
}
