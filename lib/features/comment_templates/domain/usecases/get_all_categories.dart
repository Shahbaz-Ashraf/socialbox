import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment_category.dart';
import '../repositories/comment_repository.dart';

class GetAllCategories extends UseCase<List<CommentCategory>, NoParams> {
  GetAllCategories(this._repo);
  final CommentRepository _repo;

  @override
  Future<Either<Failure, List<CommentCategory>>> call(NoParams params) =>
      _repo.getAllCategories();
}
