import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/posting_log.dart';

abstract class LogRepository {
  Stream<List<PostingLog>> watchAllLogs();
  Stream<List<PostingLog>> watchLogsForPost(String postId);
  Future<Either<Failure, List<PostingLog>>> getAllLogs(LogFilter filter);
  Future<Either<Failure, List<PostingLog>>> getLogsForPost(String postId);
  Future<Either<Failure, PostingLog>> createLog(CreateLogParams params);
  Future<Either<Failure, Unit>> deleteLog(String id);
}
