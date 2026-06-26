import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment_category.dart';
import '../repositories/comment_repository.dart';

class WatchCategories
    extends StreamUseCase<List<CommentCategory>, NoParams> {
  WatchCategories(this._repo);
  final CommentRepository _repo;

  @override
  Stream<Either<Failure, List<CommentCategory>>> call(NoParams params) {
    return _repo
        .watchCategories()
        .map((list) => Right<Failure, List<CommentCategory>>(list));
  }
}

class WatchCommentsByCategory extends StreamUseCase<List<Comment>, String> {
  WatchCommentsByCategory(this._repo);
  final CommentRepository _repo;

  @override
  Stream<Either<Failure, List<Comment>>> call(String params) {
    return _repo
        .watchCommentsByCategory(params)
        .map((list) => Right<Failure, List<Comment>>(list));
  }
}