import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../domain/entities/posting_log.dart';
import '../../domain/repositories/log_repository.dart';
import '../datasources/log_local_datasource.dart';
import '../models/posting_log_model.dart';

const _uuid = Uuid();

class LogRepositoryImpl implements LogRepository {
  LogRepositoryImpl(this._local);
  final LogLocalDataSource _local;

  @override
  Stream<List<PostingLog>> watchAllLogs() {
    return _local.watchAll().map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Stream<List<PostingLog>> watchLogsForPost(String postId) {
    return _local.watchForPost(postId).map(
        (rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Future<Either<Failure, List<PostingLog>>> getAllLogs(LogFilter filter) async {
    try {
      final rows = await _local.getAll();
      var list = rows.map((r) => r.toDomain()).toList();
      if (filter.platform != null) {
        list = list.where((l) => l.platform == filter.platform).toList();
      }
      if (filter.status != null) {
        list = list.where((l) => l.status == filter.status).toList();
      }
      return Right(list);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostingLog>>> getLogsForPost(String postId) async {
    try {
      final rows = await _local.getForPost(postId);
      return Right(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostingLog>> createLog(CreateLogParams params) async {
    try {
      final id = _uuid.v4();
      final companion = params.toCompanion(id);
      await _local.insert(companion);
      return Right(PostingLog(
        id: id,
        postId: params.postId,
        platform: params.platform,
        status: params.status,
        method: params.method,
        postedAt: params.postedAt ?? DateTime.now(),
        externalPostId: params.externalPostId,
        externalPostUrl: params.externalPostUrl,
        errorMessage: params.errorMessage,
        notes: params.notes,
        createdAt: DateTime.now(),
      ));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostingLog>> updateLogStatus(
    String id,
    LogStatus status,
  ) async {
    try {
      final row = await _local.getById(id);
      if (row == null) {
        return const Left(NotFoundFailure(message: 'Log entry not found.'));
      }
      final domain = row.toDomain().copyWith(status: status);
      await _local.update(domain.toCompanion());
      return Right(domain);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteLog(String id) async {
    try {
      await _local.delete(id);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
