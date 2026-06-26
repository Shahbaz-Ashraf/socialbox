import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../comment_templates/domain/repositories/comment_repository.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class GetSettings extends UseCase<AppSettings, NoParams> {
  GetSettings(this._repo);
  final SettingsRepository _repo;

  @override
  Future<Either<Failure, AppSettings>> call(NoParams params) async {
    try {
      return Right(_repo.getSettings());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}

class UpdateSettings extends UseCase<Unit, AppSettings> {
  UpdateSettings(this._repo);
  final SettingsRepository _repo;

  @override
  Future<Either<Failure, Unit>> call(AppSettings params) async {
    try {
      await _repo.saveSettings(params);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}

class ExportCommentsCsv extends UseCase<String, NoParams> {
  ExportCommentsCsv(this._commentRepo);
  final CommentRepository _commentRepo;

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    try {
      final catsRes = await _commentRepo.getAllCategories();
      return await catsRes.fold(
        (f) async => Left(f),
        (cats) async {
          final buffer =
              StringBuffer('category,emoji,text,tags,favorites,copies\n');
          for (final c in cats) {
            final list = await _commentRepo.getCommentsByCategory(c.id);
            final folded = list.fold(
              (f) => null,
              (comments) => comments,
            );
            if (folded == null) continue;
            for (final m in folded) {
              final escaped =
                  m.text.replaceAll('"', '""').replaceAll('\n', ' ');
              final tags = m.tags.join('|');
              buffer.writeln(
                  '"${c.name}","${c.icon}","$escaped","$tags",${m.isFavorite},${m.usageCount}');
            }
          }
          return Right(buffer.toString());
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}