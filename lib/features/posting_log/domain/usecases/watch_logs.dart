import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/posting_log.dart';
import '../repositories/log_repository.dart';

class WatchAllLogs extends StreamUseCase<List<PostingLog>, NoParams> {
  WatchAllLogs(this._repo);
  final LogRepository _repo;

  @override
  Stream<Either<Failure, List<PostingLog>>> call(NoParams params) {
    return _repo
        .watchAllLogs()
        .map((list) => Right<Failure, List<PostingLog>>(list));
  }
}