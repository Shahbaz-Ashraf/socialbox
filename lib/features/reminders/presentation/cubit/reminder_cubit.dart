import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/notification_service.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';

abstract class ReminderState extends Equatable {
  const ReminderState();
  @override
  List<Object?> get props => [];
}

class ReminderInitial extends ReminderState {
  const ReminderInitial();
}

class ReminderLoading extends ReminderState {
  const ReminderLoading();
}

class ReminderLoaded extends ReminderState {
  const ReminderLoaded({required this.reminders});
  final List<Reminder> reminders;

  List<Reminder> get upcoming => reminders
      .where((r) =>
          r.isEnabled && r.scheduledAt.isAfter(DateTime.now().subtract(const Duration(minutes: 1))))
      .toList();

  List<Reminder> get past =>
      reminders.where((r) => r.scheduledAt.isBefore(DateTime.now())).toList();

  @override
  List<Object?> get props => [reminders];
}

class ReminderError extends ReminderState {
  const ReminderError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class ReminderCubit extends Cubit<ReminderState> {
  ReminderCubit({
    required this.repository,
    required this.notificationService,
  }) : super(const ReminderInitial()) {
    _subscribe();
  }

  final ReminderRepository repository;
  final NotificationService notificationService;
  StreamSubscription? _sub;

  void _subscribe() {
    _sub?.cancel();
    _sub = repository.watchAll().listen(
      (rs) {
        // Cancel notifications for deleted reminders
        // (Stream only emits current set)
        final s = state;
        if (s is ReminderLoaded) {
          emit(ReminderLoaded(reminders: rs));
        } else {
          emit(ReminderLoaded(reminders: rs));
        }
        // Schedule upcoming reminders
        for (final r in rs) {
          if (r.isEnabled && r.scheduledAt.isAfter(DateTime.now())) {
            notificationService.scheduleReminder(
              id: r.notificationId,
              title: r.title,
              body: r.body,
              scheduledAt: r.scheduledAt,
              matchComponent: r.matchComponent,
              payload: r.postId,
            );
          }
        }
      },
    );
  }

  Future<bool> create(CreateReminderParams params) async {
    final r = await repository.create(params);
    return r.fold(
      (f) => false,
      (reminder) async {
        if (reminder.isEnabled && reminder.scheduledAt.isAfter(DateTime.now())) {
          await notificationService.scheduleReminder(
            id: reminder.notificationId,
            title: reminder.title,
            body: reminder.body,
            scheduledAt: reminder.scheduledAt,
            matchComponent: reminder.matchComponent,
            payload: reminder.postId,
          );
        }
        return true;
      },
    );
  }

  Future<bool> update(Reminder original, UpdateReminderParams params) async {
    await notificationService.cancelReminder(original.notificationId);
    final r = await repository.update(params);
    return r.fold((f) => false, (reminder) async {
      if (reminder.isEnabled && reminder.scheduledAt.isAfter(DateTime.now())) {
        await notificationService.scheduleReminder(
          id: reminder.notificationId,
          title: reminder.title,
          body: reminder.body,
          scheduledAt: reminder.scheduledAt,
          matchComponent: reminder.matchComponent,
          payload: reminder.postId,
        );
      }
      return true;
    });
  }

  Future<bool> delete(Reminder r) async {
    await notificationService.cancelReminder(r.notificationId);
    final res = await repository.delete(r.id);
    return res.isRight();
  }

  Future<bool> toggle(Reminder r) async {
    final res = await repository.toggle(r.id);
    return res.fold(
      (f) => false,
      (updated) async {
        if (!updated.isEnabled) {
          await notificationService.cancelReminder(updated.notificationId);
        } else if (updated.scheduledAt.isAfter(DateTime.now())) {
          await notificationService.scheduleReminder(
            id: updated.notificationId,
            title: updated.title,
            body: updated.body,
            scheduledAt: updated.scheduledAt,
            matchComponent: updated.matchComponent,
            payload: updated.postId,
          );
        }
        return true;
      },
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
