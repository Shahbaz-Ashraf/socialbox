import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/reminder_local_datasource.dart';
import '../models/reminder_model.dart';

const _uuid = Uuid();

class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl(this._local);
  final ReminderLocalDataSource _local;

  @override
  Stream<List<Reminder>> watchAll() =>
      _local.watchAll().map((rows) => rows.map((r) => r.toDomain()).toList());

  @override
  Stream<List<Reminder>> watchForPost(String postId) => _local
      .watchForPost(postId)
      .map((rows) => rows.map((r) => r.toDomain()).toList());

  @override
  Future<Either<Failure, List<Reminder>>> getAll() async {
    try {
      final rows = await _local.getAll();
      return Right(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  int _generateNotificationId(String id) => id.hashCode.abs() % 100000;

  @override
  Future<Either<Failure, Reminder>> create(CreateReminderParams p) async {
    try {
      final id = _uuid.v4();
      final nid = _generateNotificationId(id);
      await _local.insert(p.toCompanion(id: id, notificationId: nid));
      return Right(Reminder(
        id: id,
        postId: p.postId,
        title: p.title,
        body: p.body,
        scheduledAt: p.scheduledAt,
        repeat: p.repeat,
        repeatDays: p.repeatDays,
        isEnabled: true,
        notificationId: nid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reminder>> update(UpdateReminderParams p) async {
    try {
      await _local.update(p.toCompanion());
      final fresh = await _local.getById(p.id);
      if (fresh == null) {
        return const Left(NotFoundFailure(message: 'Reminder not found.'));
      }
      return Right(fresh.toDomain());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      await _local.delete(id);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reminder>> toggle(String id) async {
    try {
      await _local.toggle(id);
      final fresh = await _local.getById(id);
      if (fresh == null) {
        return const Left(NotFoundFailure(message: 'Reminder not found.'));
      }
      return Right(fresh.toDomain());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
