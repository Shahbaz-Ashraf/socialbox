import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

class WatchAllReminders extends StreamUseCase<List<Reminder>, NoParams> {
  WatchAllReminders(this._repo);
  final ReminderRepository _repo;

  @override
  Stream<Either<Failure, List<Reminder>>> call(NoParams params) {
    return _repo
        .watchAll()
        .map((list) => Right<Failure, List<Reminder>>(list));
  }
}