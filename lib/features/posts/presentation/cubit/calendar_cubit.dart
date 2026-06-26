import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/date_range.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/social_post.dart';
import '../../domain/usecases/post_date_usecases.dart';
import '../../domain/usecases/watch_posts.dart';
import '../../../reminders/domain/entities/reminder.dart';
import '../../../reminders/domain/usecases/reminder_date_usecases.dart';
import '../../../reminders/domain/usecases/watch_reminders.dart';

class CalendarDay extends Equatable {
  const CalendarDay({required this.date, required this.posts, required this.reminders});
  final DateTime date;
  final List<SocialPost> posts;
  final List<Reminder> reminders;
  bool get isEmpty => posts.isEmpty && reminders.isEmpty;
  @override
  List<Object?> get props => [date, posts, reminders];
}

class CalendarState extends Equatable {
  const CalendarState({
    this.focusedMonth,
    this.selectedDate,
    this.days = const {},
    this.loading = false,
  });
  final DateTime? focusedMonth;
  final DateTime? selectedDate;
  final Map<DateTime, CalendarDay> days;
  final bool loading;

  CalendarState copyWith({
    DateTime? focusedMonth,
    DateTime? selectedDate,
    Map<DateTime, CalendarDay>? days,
    bool? loading,
  }) =>
      CalendarState(
        focusedMonth: focusedMonth ?? this.focusedMonth,
        selectedDate: selectedDate ?? this.selectedDate,
        days: days ?? this.days,
        loading: loading ?? this.loading,
      );

  @override
  List<Object?> get props => [focusedMonth, selectedDate, days, loading];
}

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit({
    required GetPostsInRange getPostsInRange,
    required GetRemindersInRange getRemindersInRange,
    required WatchAllPosts watchAllPosts,
    required WatchAllReminders watchAllReminders,
  })  : _getPostsInRange = getPostsInRange,
        _getRemindersInRange = getRemindersInRange,
        _watchAllPosts = watchAllPosts,
        _watchAllReminders = watchAllReminders,
        super(CalendarState(
          focusedMonth: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            1,
          ),
          selectedDate: DateTime.now(),
        ));

  final GetPostsInRange _getPostsInRange;
  final GetRemindersInRange _getRemindersInRange;
  final WatchAllPosts _watchAllPosts;
  final WatchAllReminders _watchAllReminders;

  StreamSubscription? _postsSub;
  StreamSubscription? _remindersSub;

  void start() {
    _postsSub?.cancel();
    _remindersSub?.cancel();
    _postsSub = _watchAllPosts(const NoParams()).listen((_) => _refresh());
    _remindersSub =
        _watchAllReminders(const NoParams()).listen((_) => _refresh());
  }

  void selectDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    emit(state.copyWith(selectedDate: day));
  }

  void focusMonth(DateTime month) {
    emit(state.copyWith(
      focusedMonth: DateTime(month.year, month.month, 1),
    ));
    _refresh();
  }

  Future<void> _refresh() async {
    final month = state.focusedMonth;
    if (month == null) return;
    emit(state.copyWith(loading: true));
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final range = DateRange(start: start, end: end);

    final posts = await _getPostsInRange(range);
    final reminders = await _getRemindersInRange(range);

    final days = <DateTime, CalendarDay>{};

    posts.fold((_) {}, (list) {
      for (final p in list) {
        final s = p.scheduledAt;
        if (s == null) continue;
        final key = DateTime(s.year, s.month, s.day);
        final cur = days[key] ??
            CalendarDay(date: key, posts: const [], reminders: const []);
        days[key] = CalendarDay(
          date: key,
          posts: [...cur.posts, p],
          reminders: cur.reminders,
        );
      }
    });
    reminders.fold((_) {}, (list) {
      for (final r in list) {
        final s = r.scheduledAt;
        final key = DateTime(s.year, s.month, s.day);
        final cur = days[key] ??
            CalendarDay(date: key, posts: const [], reminders: const []);
        days[key] = CalendarDay(
          date: key,
          posts: cur.posts,
          reminders: [...cur.reminders, r],
        );
      }
    });

    emit(state.copyWith(days: days, loading: false));
  }

  CalendarDay? dayAt(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return state.days[key];
  }

  @override
  Future<void> close() {
    _postsSub?.cancel();
    _remindersSub?.cancel();
    return super.close();
  }
}