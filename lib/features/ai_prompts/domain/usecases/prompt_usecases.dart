import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/prompt_config.dart';
import '../repositories/prompt_repository.dart';

class LoadPromptTemplate extends UseCase<String, NoParams> {
  LoadPromptTemplate(this._repo);
  final PromptRepository _repo;

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    try {
      return Right(_repo.loadTemplate());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}

class SavePromptTemplate extends UseCase<Unit, String> {
  SavePromptTemplate(this._repo);
  final PromptRepository _repo;

  @override
  Future<Either<Failure, Unit>> call(String params) async {
    try {
      await _repo.saveTemplate(params);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}

class ResetPromptTemplate extends UseCase<String, NoParams> {
  ResetPromptTemplate(this._repo);
  final PromptRepository _repo;

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    try {
      await _repo.resetTemplate();
      return Right(_repo.loadTemplate());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}

class LoadLastPromptConfig extends UseCase<PromptConfig, NoParams> {
  LoadLastPromptConfig(this._repo);
  final PromptRepository _repo;

  @override
  Future<Either<Failure, PromptConfig>> call(NoParams params) async {
    try {
      return Right(_repo.loadLastConfig());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}

class SaveLastPromptConfig extends UseCase<Unit, PromptConfig> {
  SaveLastPromptConfig(this._repo);
  final PromptRepository _repo;

  @override
  Future<Either<Failure, Unit>> call(PromptConfig params) async {
    try {
      await _repo.saveLastConfig(params);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}

class LoadPromptPresets extends UseCase<List<PromptPreset>, NoParams> {
  LoadPromptPresets(this._repo);
  final PromptRepository _repo;

  @override
  Future<Either<Failure, List<PromptPreset>>> call(NoParams params) async {
    try {
      return Right(_repo.loadPresets());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}

class SavePromptPresets extends UseCase<Unit, List<PromptPreset>> {
  SavePromptPresets(this._repo);
  final PromptRepository _repo;

  @override
  Future<Either<Failure, Unit>> call(List<PromptPreset> params) async {
    try {
      await _repo.savePresets(params);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}