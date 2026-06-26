import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../injection_container.dart';
import '../../../reminders/domain/entities/reminder.dart';
import '../../../reminders/domain/repositories/reminder_repository.dart';
import '../../domain/entities/social_post.dart';
import '../../domain/repositories/post_repository.dart';
import '../cubit/calendar_cubit.dart';
import '../widgets/post_status_badge.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = CalendarCubit(
          postRepository: getIt<PostRepository>(),
          reminderRepository: getIt<ReminderRepository>(),
        );
        cubit.start();
        return cubit;
      },
      child: const _CalendarView(),
    );
  }
}

class _CalendarView extends StatefulWidget {
  const _CalendarView();
  @override
  State<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView> {
  CalendarFormat _format = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            tooltip: 'New post on selected day',
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              final date = context.read<CalendarCubit>().state.selectedDate;
              if (date == null) return;
              context.pushNamed(
                RouteNames.createPost,
                queryParameters: {
                  'prefillDate': date.toIso8601String(),
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CalendarCubit, CalendarState>(
        builder: (context, state) {
          final focused = state.focusedMonth ?? DateTime.now();
          final selected = state.selectedDate ?? DateTime.now();
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2035, 12, 31),
                  focusedDay: focused,
                  selectedDayPredicate: (d) => isSameDay(d, selected),
                  calendarFormat: _format,
                  eventLoader: (day) {
                    final k = DateTime(day.year, day.month, day.day);
                    final entry = state.days[k];
                    if (entry == null) return const [];
                    return [
                      ...entry.posts,
                      ...entry.reminders,
                    ];
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    context.read<CalendarCubit>().selectDate(selectedDay);
                    context
                        .read<CalendarCubit>()
                        .focusMonth(focusedDay);
                  },
                  onFormatChanged: (f) => setState(() => _format = f),
                  onPageChanged: (focusedDay) {
                    context.read<CalendarCubit>().focusMonth(focusedDay);
                  },
                  calendarStyle: CalendarStyle(
                    markerDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (state.loading)
                const LoadingState(message: 'Loading items…')
              else
                _DayDetails(date: selected, day: state.days[DateTime(
                    selected.year, selected.month, selected.day)]),
            ],
          );
        },
      ),
    );
  }
}

class _DayDetails extends StatelessWidget {
  const _DayDetails({required this.date, required this.day});
  final DateTime date;
  final CalendarDay? day;

  @override
  Widget build(BuildContext context) {
    final posts = day?.posts ?? const <SocialPost>[];
    final reminders = day?.reminders ?? const [];
    if (posts.isEmpty && reminders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: EmptyState(
          icon: Icons.event_busy_rounded,
          title: 'Nothing on ${AppDateUtils.formatShortDate(date)}',
          message: 'Schedule a post or set a reminder for this day.',
          actionLabel: 'New Post',
          onAction: () => context.pushNamed(
            RouteNames.createPost,
            queryParameters: {'prefillDate': date.toIso8601String()},
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Text(
              AppDateUtils.formatDate(date),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (posts.isNotEmpty) ...[
            const _SectionLabel('Posts'),
            ...posts.map((p) => _PostTile(post: p)),
            const SizedBox(height: 12),
          ],
          if (reminders.isNotEmpty) ...[
            const _SectionLabel('Reminders'),
            ...reminders.map((r) => _ReminderTile(reminder: r)),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4, top: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _PostTile extends StatelessWidget {
  const _PostTile({required this.post});
  final SocialPost post;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.send_rounded),
        title: Text(post.title,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          post.scheduledAt != null
              ? AppDateUtils.formatTime(post.scheduledAt!)
              : '',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: PostStatusBadge(status: post.status),
        onTap: () => context.pushNamed(
          RouteNames.postDetail,
          pathParameters: {'id': post.id},
        ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.reminder});
  final Reminder reminder;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(reminder.repeat.icon, color: reminder.repeat.color),
        title: Text(reminder.title,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          AppDateUtils.formatTime(reminder.scheduledAt),
          style: const TextStyle(fontSize: 12),
        ),
        onTap: () => context.pushNamed(RouteNames.reminders),
      ),
    );
  }
}
