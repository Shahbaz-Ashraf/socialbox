import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/reminder.dart';

abstract class ReminderRepository {
  Stream<List<Reminder>> watchAll();
  Stream<List<Reminder>> watchForPost(String postId);
  Future<Either<Failure, List<Reminder>>> getAll();
  Future<Either<Failure, Reminder>> create(CreateReminderParams params);
  Future<Either<Failure, Reminder>> update(UpdateReminderParams params);
  Future<Either<Failure, Unit>> delete(String id);
  Future<Either<Failure, Reminder>> toggle(String id);
}
