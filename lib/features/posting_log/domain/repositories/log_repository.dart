import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/platform_utils.dart';
import '../entities/posting_log.dart';

abstract class LogRepository {
  Stream<List<PostingLog>> watchAllLogs();
  Stream<List<PostingLog>> watchLogsForPost(String postId);
  Future<Either<Failure, List<PostingLog>>> getAllLogs(LogFilter filter);
  Future<Either<Failure, List<PostingLog>>> getLogsForPost(String postId);
  Future<Either<Failure, PostingLog>> createLog(CreateLogParams params);
  Future<Either<Failure, PostingLog>> updateLogStatus(
    String id,
    LogStatus status,
  );
  Future<Either<Failure, Unit>> deleteLog(String id);
}
