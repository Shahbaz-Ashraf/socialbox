import 'package:flutter/material.dart' show DateTimeRange;
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

class GetRemindersInRange extends UseCase<List<Reminder>, DateTimeRange> {
  GetRemindersInRange(this._repo);
  final ReminderRepository _repo;

  @override
  Future<Either<Failure, List<Reminder>>> call(DateTimeRange params) async {
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
