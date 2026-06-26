import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment_category.dart';
import '../repositories/comment_repository.dart';

class CreateCategoryParams extends Equatable {
  const CreateCategoryParams({
    required this.name,
    required this.icon,
    required this.colorHex,
  });

  final String name;
  final String icon;
  final String colorHex;

  @override
  List<Object?> get props => [name, icon, colorHex];
}

class CreateCategory extends UseCase<CommentCategory, CreateCategoryParams> {
  CreateCategory(this._repo);
  final CommentRepository _repo;

  @override
  Future<Either<Failure, CommentCategory>> call(
          CreateCategoryParams params) =>
      _repo.createCategory(
        name: params.name,
        icon: params.icon,
        colorHex: params.colorHex,
      );
}

class UpdateCategory extends UseCase<CommentCategory, CommentCategory> {
  UpdateCategory(this._repo);
  final CommentRepository _repo;

  @override
  Future<Either<Failure, CommentCategory>> call(CommentCategory params) =>
      _repo.updateCategory(params);
}

class DeleteCategory extends UseCase<Unit, String> {
  DeleteCategory(this._repo);
  final CommentRepository _repo;

  @override
  Future<Either<Failure, Unit>> call(String params) =>
      _repo.deleteCategory(params);
}
