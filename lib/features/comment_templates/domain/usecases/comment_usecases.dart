import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment_category.dart';
import '../repositories/comment_repository.dart';

class GetCommentsByCategory extends UseCase<List<Comment>, String> {
  GetCommentsByCategory(this._repo);
  final CommentRepository _repo;

  @override
  Future<Either<Failure, List<Comment>>> call(String params) =>
      _repo.getCommentsByCategory(params);
}

class SearchComments extends UseCase<List<Comment>, String> {
  SearchComments(this._repo);
  final CommentRepository _repo;

  @override
  Future<Either<Failure, List<Comment>>> call(String params) =>
      _repo.searchComments(params);
}

class CreateCommentParams extends Equatable {
  const CreateCommentParams({
    required this.categoryId,
    required this.text,
    this.tags = const [],
  });

  final String categoryId;
  final String text;
  final List<String> tags;

  @override
  List<Object?> get props => [categoryId, text, tags];
}

class CreateComment extends UseCase<Comment, CreateCommentParams> {
  CreateComment(this._repo);
  final CommentRepository _repo;

  @override
  Future<Either<Failure, Comment>> call(CreateCommentParams params) =>
      _repo.createComment(
        categoryId: params.categoryId,
        text: params.text,
        tags: params.tags,
      );
}

class UpdateComment extends UseCase<Comment, Comment> {
  UpdateComment(this._repo);
  final CommentRepository _repo;

  @override
  Future<Either<Failure, Comment>> call(Comment params) =>
      _repo.updateComment(params);
}

class DeleteComment extends UseCase<Unit, String> {
  DeleteComment(this._repo);
  final CommentRepository _repo;

  @override
  Future<Either<Failure, Unit>> call(String params) =>
      _repo.deleteComment(params);
}

class ToggleFavorite extends UseCase<Comment, String> {
  ToggleFavorite(this._repo);
  final CommentRepository _repo;

  @override
  Future<Either<Failure, Comment>> call(String params) =>
      _repo.toggleFavorite(params);
}

class IncrementUsageCount extends UseCase<Unit, String> {
  IncrementUsageCount(this._repo);
  final CommentRepository _repo;

  @override
  Future<Either<Failure, Unit>> call(String params) =>
      _repo.incrementUsageCount(params);
}
