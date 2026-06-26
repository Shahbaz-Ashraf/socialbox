import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/posting_log.dart';
import '../repositories/log_repository.dart';

class GetLogsForPost extends UseCase<List<PostingLog>, String> {
  GetLogsForPost(this._repo);
  final LogRepository _repo;

  @override
  Future<Either<Failure, List<PostingLog>>> call(String params) =>
      _repo.getLogsForPost(params);
}

class GetAllLogs extends UseCase<List<PostingLog>, LogFilter> {
  GetAllLogs(this._repo);
  final LogRepository _repo;

  @override
  Future<Either<Failure, List<PostingLog>>> call(LogFilter params) =>
      _repo.getAllLogs(params);
}

class CreateLogEntry extends UseCase<PostingLog, CreateLogParams> {
  CreateLogEntry(this._repo);
  final LogRepository _repo;

  @override
  Future<Either<Failure, PostingLog>> call(CreateLogParams params) =>
      _repo.createLog(params);
}

class UpdateLogStatusParams extends Equatable {
  const UpdateLogStatusParams({required this.id, required this.status});

  final String id;
  final LogStatus status;

  @override
  List<Object?> get props => [id, status];
}

class UpdateLogStatus extends UseCase<PostingLog, UpdateLogStatusParams> {
  UpdateLogStatus(this._repo);
  final LogRepository _repo;

  @override
  Future<Either<Failure, PostingLog>> call(UpdateLogStatusParams params) =>
      _repo.updateLogStatus(params.id, params.status);
}

class DeleteLog extends UseCase<Unit, String> {
  DeleteLog(this._repo);
  final LogRepository _repo;

  @override
  Future<Either<Failure, Unit>> call(String params) => _repo.deleteLog(params);
}
