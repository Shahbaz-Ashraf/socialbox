import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../cubit/reminder_cubit.dart';
import '../widgets/reminder_form_sheet.dart';
import '../widgets/reminder_tile.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({
    super.key,
    this.prefillTitle,
    this.prefillTime,
    this.postId,
    this.autoOpenForm = false,
  });

  final String? prefillTitle;
  final DateTime? prefillTime;
  final String? postId;
  final bool autoOpenForm;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReminderCubit(
        repository: getIt<ReminderRepository>(),
        notificationService: getIt<NotificationService>(),
        settingsRepository: getIt(),
      ),
      child: _RemindersView(
        prefillTitle: prefillTitle,
        prefillTime: prefillTime,
        postId: postId,
        autoOpenForm: autoOpenForm,
      ),
    );
  }
}

class _RemindersView extends StatefulWidget {
  const _RemindersView({
    this.prefillTitle,
    this.prefillTime,
    this.postId,
    this.autoOpenForm = false,
  });

  final String? prefillTitle;
  final DateTime? prefillTime;
  final String? postId;
  final bool autoOpenForm;

  @override
  State<_RemindersView> createState() => _RemindersViewState();
}

class _RemindersViewState extends State<_RemindersView> {
  @override
  void initState() {
    super.initState();
    if (widget.autoOpenForm) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showForm(
            context,
            prefillTitle: widget.prefillTitle,
            prefillTime: widget.prefillTime,
            linkedPostId: widget.postId,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_alert_rounded),
        label: const Text('Reminder'),
        onPressed: () => _showForm(context),
      ),
      body: BlocBuilder<ReminderCubit, ReminderState>(
        builder: (context, state) {
          if (state is ReminderLoading || state is ReminderInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReminderLoaded) {
            if (state.reminders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_off_rounded,
                      size: 96,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(height: 12),
                    const Text('No reminders yet'),
                    const SizedBox(height: 6),
                    const Text('Tap + to create your first reminder.'),
                  ],
                ),
              );
            }
            final upcoming = state.upcoming;
            final past = state.past;
            return ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                if (upcoming.isNotEmpty) ...[
                  _Header('Upcoming (${upcoming.length})'),
                  ...upcoming.map(
                    (r) => Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: ReminderTile(
                        reminder: r,
                        onToggle: (_) =>
                            context.read<ReminderCubit>().toggle(r),
                        onTap: () => _showForm(context, existing: r),
                        onDelete: () => _confirmDelete(context, r),
                      ),
                    ),
                  ),
                ],
                if (past.isNotEmpty) ...[
                  _Header('Past (${past.length})'),
                  ...past.map(
                    (r) => Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: ReminderTile(
                        reminder: r,
                        onToggle: (_) =>
                            context.read<ReminderCubit>().toggle(r),
                        onTap: () => _showForm(context, existing: r),
                        onDelete: () => _confirmDelete(context, r),
                      ),
                    ),
                  ),
                ],
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showForm(
    BuildContext context, {
    Reminder? existing,
    String? prefillTitle,
    DateTime? prefillTime,
    String? linkedPostId,
  }) {
    final cubit = context.read<ReminderCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ReminderFormSheet(
        initial: existing,
        prefillTitle: prefillTitle,
        prefillTime: prefillTime,
        linkedPostId: linkedPostId,
        onSubmit: (params) async {
          if (existing == null) {
            return await cubit.create(params);
          } else {
            return await cubit.update(
              existing,
              UpdateReminderParams(
                id: existing.id,
                title: params.title,
                body: params.body,
                postId: params.postId,
                scheduledAt: params.scheduledAt,
                repeat: params.repeat,
                repeatDays: params.repeatDays,
                isEnabled: existing.isEnabled,
                notificationId: existing.notificationId,
                createdAt: existing.createdAt,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Reminder r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete reminder?'),
        content: const Text('This reminder will be cancelled and removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await context.read<ReminderCubit>().delete(r);
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}