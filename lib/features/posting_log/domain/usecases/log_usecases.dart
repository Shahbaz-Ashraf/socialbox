import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
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

class DeleteLog extends UseCase<Unit, String> {
  DeleteLog(this._repo);
  final LogRepository _repo;

  @override
  Future<Either<Failure, Unit>> call(String params) => _repo.deleteLog(params);
}
