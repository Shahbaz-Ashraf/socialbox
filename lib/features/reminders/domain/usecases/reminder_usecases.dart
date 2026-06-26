import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

class GetAllReminders extends UseCase<List<Reminder>, NoParams> {
  GetAllReminders(this._repo);
  final ReminderRepository _repo;

  @override
  Future<Either<Failure, List<Reminder>>> call(NoParams params) =>
      _repo.getAll();
}

class GetRemindersForPost extends UseCase<List<Reminder>, String> {
  GetRemindersForPost(this._repo);
  final ReminderRepository _repo;

  @override
  Future<Either<Failure, List<Reminder>>> call(String params) =>
      _repo.getAll();
}

class CreateReminder extends UseCase<Reminder, CreateReminderParams> {
  CreateReminder(this._repo);
  final ReminderRepository _repo;

  @override
  Future<Either<Failure, Reminder>> call(CreateReminderParams params) =>
      _repo.create(params);
}

class UpdateReminder extends UseCase<Reminder, UpdateReminderParams> {
  UpdateReminder(this._repo);
  final ReminderRepository _repo;

  @override
  Future<Either<Failure, Reminder>> call(UpdateReminderParams params) =>
      _repo.update(params);
}

class DeleteReminder extends UseCase<Unit, String> {
  DeleteReminder(this._repo);
  final ReminderRepository _repo;

  @override
  Future<Either<Failure, Unit>> call(String params) => _repo.delete(params);
}

class ToggleReminder extends UseCase<Reminder, String> {
  ToggleReminder(this._repo);
  final ReminderRepository _repo;

  @override
  Future<Either<Failure, Reminder>> call(String params) => _repo.toggle(params);
}
