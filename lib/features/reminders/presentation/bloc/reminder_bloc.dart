import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../posts/domain/entities/social_post.dart';
import '../../../posts/domain/usecases/post_usecases.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../data/mappers/reminder_notification_mapper.dart';
import '../../data/mappers/reminder_notification_platform_mapper.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

sealed class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object?> get props => [];
}

final class ReminderLoad extends ReminderEvent {
  const ReminderLoad();
}

final class ReminderCreate extends ReminderEvent {
  const ReminderCreate(this.params);

  final CreateReminderParams params;

  @override
  List<Object?> get props => [params];
}

final class ReminderUpdate extends ReminderEvent {
  const ReminderUpdate({
    required this.original,
    required this.params,
  });

  final Reminder original;
  final UpdateReminderParams params;

  @override
  List<Object?> get props => [original, params];
}

final class ReminderDelete extends ReminderEvent {
  const ReminderDelete(this.reminder);

  final Reminder reminder;

  @override
  List<Object?> get props => [reminder];
}

final class ReminderToggle extends ReminderEvent {
  const ReminderToggle(this.reminder);

  final Reminder reminder;

  @override
  List<Object?> get props => [reminder];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

sealed class ReminderState extends Equatable {
  const ReminderState();

  @override
  List<Object?> get props => [];
}

final class ReminderInitial extends ReminderState {
  const ReminderInitial();
}

final class ReminderLoading extends ReminderState {
  const ReminderLoading();
}

final class ReminderLoaded extends ReminderState {
  const ReminderLoaded({required this.reminders});

  final List<Reminder> reminders;

  List<Reminder> get upcoming => reminders
      .where((r) =>
          r.isEnabled &&
          r.scheduledAt.isAfter(DateTime.now().subtract(const Duration(minutes: 1))))
      .toList();

  List<Reminder> get past =>
      reminders.where((r) => r.scheduledAt.isBefore(DateTime.now())).toList();

  @override
  List<Object?> get props => [reminders];
}

final class ReminderError extends ReminderState {
  const ReminderError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// Bloc
// ---------------------------------------------------------------------------

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  ReminderBloc({
    required this.repository,
    required this.notificationService,
    required this.settingsRepository,
    required this.getAllPosts,
  }) : super(const ReminderInitial()) {
    on<ReminderLoad>(_onLoad);
    on<ReminderCreate>(_onCreate);
    on<ReminderUpdate>(_onUpdate);
    on<ReminderDelete>(_onDelete);
    on<ReminderToggle>(_onToggle);
    add(const ReminderLoad());
  }

  final ReminderRepository repository;
  final NotificationService notificationService;
  final SettingsRepository settingsRepository;
  final GetAllPosts getAllPosts;

  StreamSubscription<List<Reminder>>? _sub;

  Future<List<SocialPost>> loadLinkablePosts() async {
    final result = await getAllPosts(const NoParams());
    return result.getOrElse((_) => const []);
  }

  bool get _notificationsEnabled =>
      settingsRepository.getSettings().enableNotifications;

  /// Notification fires [reminderLeadMinutes] before [scheduledAt].
  /// If that time is already past, schedule a few seconds from now.
  DateTime _notificationAt(DateTime scheduledAt) {
    final lead = settingsRepository.getSettings().reminderLeadMinutes;
    final at = scheduledAt.subtract(Duration(minutes: lead));
    final now = DateTime.now();
    if (at.isBefore(now)) {
      return now.add(const Duration(seconds: 5));
    }
    return at;
  }

  Future<void> _onLoad(ReminderLoad event, Emitter<ReminderState> emit) async {
    emit(const ReminderLoading());
    await _subscribe(emit);
  }

  Future<void> _subscribe(Emitter<ReminderState> emit) async {
    await _sub?.cancel();
    _sub = repository.watchAll().listen(
      (reminders) {
        emit(ReminderLoaded(reminders: reminders));
        _scheduleNotifications(reminders);
      },
      onError: (Object error) {
        emit(ReminderError(error.toString()));
      },
    );
  }

  void _scheduleNotifications(List<Reminder> reminders) {
    if (!_notificationsEnabled) return;
    for (final r in reminders) {
      if (r.isEnabled && r.scheduledAt.isAfter(DateTime.now())) {
        notificationService.scheduleReminder(
          id: r.notificationId,
          title: r.title,
          body: r.body,
          scheduledAt: _notificationAt(r.scheduledAt),
          matchComponent: toDateTimeComponents(reminderMatchComponent(r)),
          payload: r.postId,
        );
      }
    }
  }

  Future<void> _onCreate(
    ReminderCreate event,
    Emitter<ReminderState> emit,
  ) async {
    await _performCreate(event.params);
  }

  Future<void> _onUpdate(
    ReminderUpdate event,
    Emitter<ReminderState> emit,
  ) async {
    await _performUpdate(event.original, event.params);
  }

  Future<void> _onDelete(
    ReminderDelete event,
    Emitter<ReminderState> emit,
  ) async {
    await _performDelete(event.reminder);
  }

  Future<void> _onToggle(
    ReminderToggle event,
    Emitter<ReminderState> emit,
  ) async {
    await _performToggle(event.reminder);
  }

  /// Used by [ReminderFormSheet] which needs a success/failure result.
  Future<bool> create(CreateReminderParams params) => _performCreate(params);

  /// Used by [ReminderFormSheet] which needs a success/failure result.
  Future<bool> update(Reminder original, UpdateReminderParams params) =>
      _performUpdate(original, params);

  Future<bool> _performCreate(CreateReminderParams params) async {
    final r = await repository.create(params);
    return r.fold(
      (f) => false,
      (reminder) async {
        if (_notificationsEnabled &&
            reminder.isEnabled &&
            reminder.scheduledAt.isAfter(DateTime.now())) {
          await notificationService.scheduleReminder(
            id: reminder.notificationId,
            title: reminder.title,
            body: reminder.body,
            scheduledAt: _notificationAt(reminder.scheduledAt),
            matchComponent: toDateTimeComponents(reminderMatchComponent(reminder)),
            payload: reminder.postId,
          );
        }
        return true;
      },
    );
  }

  Future<bool> _performUpdate(
    Reminder original,
    UpdateReminderParams params,
  ) async {
    await notificationService.cancelReminder(original.notificationId);
    final r = await repository.update(params);
    return r.fold((f) => false, (reminder) async {
      if (_notificationsEnabled &&
          reminder.isEnabled &&
          reminder.scheduledAt.isAfter(DateTime.now())) {
        await notificationService.scheduleReminder(
          id: reminder.notificationId,
          title: reminder.title,
          body: reminder.body,
          scheduledAt: _notificationAt(reminder.scheduledAt),
          matchComponent: toDateTimeComponents(reminderMatchComponent(reminder)),
          payload: reminder.postId,
        );
      }
      return true;
    });
  }

  Future<bool> _performDelete(Reminder reminder) async {
    await notificationService.cancelReminder(reminder.notificationId);
    final res = await repository.delete(reminder.id);
    return res.isRight();
  }

  Future<bool> _performToggle(Reminder reminder) async {
    final res = await repository.toggle(reminder.id);
    return res.fold(
      (f) => false,
      (updated) async {
        if (!updated.isEnabled) {
          await notificationService.cancelReminder(updated.notificationId);
        } else if (_notificationsEnabled &&
            updated.scheduledAt.isAfter(DateTime.now())) {
          await notificationService.scheduleReminder(
            id: updated.notificationId,
            title: updated.title,
            body: updated.body,
            scheduledAt: _notificationAt(updated.scheduledAt),
            matchComponent: toDateTimeComponents(reminderMatchComponent(updated)),
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