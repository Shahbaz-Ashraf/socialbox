import 'package:fpdart/fpdart.dart';

import '../../../../core/domain/date_range.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

class GetRemindersInRange extends UseCase<List<Reminder>, DateRange> {
  GetRemindersInRange(this._repo);
  final ReminderRepository _repo;

  @override
  Future<Either<Failure, List<Reminder>>> call(DateRange params) async {
    final all = await _repo.getAll();
    return all.fold(
      (f) => Left<Failure, List<Reminder>>(f),
      (items) {
        final filtered = items
            .where((r) =>
                !r.scheduledAt.isBefore(params.start) &&
                r.scheduledAt.isBefore(params.end))
            .toList();
        return Right(filtered);
      },
    );
  }
}
