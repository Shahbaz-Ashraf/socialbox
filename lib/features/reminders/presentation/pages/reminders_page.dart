import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/scrollable_bottom_sheet.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/reminder.dart';
import '../bloc/reminder_bloc.dart';
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
      create: (_) => getIt<ReminderBloc>(),
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
      body: BlocBuilder<ReminderBloc, ReminderState>(
        builder: (context, state) {
          if (state is ReminderLoading || state is ReminderInitial) {
            return const LoadingListSkeleton(itemCount: 5, itemHeight: 88);
          }
          if (state is ReminderLoaded) {
            if (state.reminders.isEmpty) {
              return const EmptyState(
                icon: Icons.notifications_off_rounded,
                title: 'No reminders yet',
                message: 'Get notified before it is time to post.',
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
                            context.read<ReminderBloc>().add(ReminderToggle(r)),
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
                            context.read<ReminderBloc>().add(ReminderToggle(r)),
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

  Future<void> _showForm(
    BuildContext context, {
    Reminder? existing,
    String? prefillTitle,
    DateTime? prefillTime,
    String? linkedPostId,
  }) async {
    final bloc = context.read<ReminderBloc>();
    final posts = await bloc.loadLinkablePosts();
    if (!context.mounted) return;
    showScrollableBottomSheet(
      context: context,
      title: existing == null ? 'New reminder' : 'Edit reminder',
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, scrollController) => ReminderFormSheet(
        scrollController: scrollController,
        embeddedInSheet: true,
        initial: existing,
        prefillTitle: prefillTitle,
        prefillTime: prefillTime,
        linkedPostId: linkedPostId,
        posts: posts,
        onSubmit: (params) async {
          if (existing == null) {
            return await bloc.create(params);
          } else {
            return await bloc.update(
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
    context.read<ReminderBloc>().add(ReminderDelete(r));
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(text, style: AppTextStyles.sectionHeader(context)),
    );
  }
}