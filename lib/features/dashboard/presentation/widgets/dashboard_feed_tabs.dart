import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../posting_log/domain/entities/posting_log.dart';
import '../../../posts/domain/entities/social_post.dart';
import '../../../reminders/domain/entities/reminder.dart';
import 'dashboard_activity_item.dart';
import 'dashboard_list_item.dart';
import 'dashboard_section.dart';

class DashboardFeedTabs extends StatefulWidget {
  const DashboardFeedTabs({
    super.key,
    required this.posts,
    required this.reminders,
    required this.logs,
    required this.onCopyUrl,
  });

  final List<SocialPost> posts;
  final List<Reminder> reminders;
  final List<PostingLog> logs;
  final void Function(BuildContext context, String url) onCopyUrl;

  @override
  State<DashboardFeedTabs> createState() => _DashboardFeedTabsState();
}

class _DashboardFeedTabsState extends State<DashboardFeedTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) setState(() {});
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: AppDecorations.modernCard(context),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            dividerHeight: 0,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: AppTextStyles.caption.copyWith(fontSize: 12),
            tabs: [
              Tab(text: 'Schedule (${widget.posts.length})'),
              Tab(text: 'Reminders (${widget.reminders.length})'),
              Tab(text: 'Activity (${widget.logs.length})'),
            ],
          ),
          Divider(
            height: 1,
            color: theme.dividerColor.withValues(alpha: 0.4),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: KeyedSubtree(
              key: ValueKey(_tabController.index),
              child: _buildTabContent(_tabController.index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(int index) {
    return switch (index) {
      0 => _ScheduleTab(posts: widget.posts),
      1 => _RemindersTab(reminders: widget.reminders),
      _ => _ActivityTab(logs: widget.logs, onCopyUrl: widget.onCopyUrl),
    };
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab({required this.posts});
  final List<SocialPost> posts;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: DashboardEmptyState(
          message: 'No scheduled posts.',
          actionLabel: 'Create post',
          onAction: () => context.pushNamed(RouteNames.createPost),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: posts
            .take(3)
            .map(
              (p) => DashboardListItem(
                icon: Icons.schedule_outlined,
                title: p.title,
                subtitle: AppDateUtils.formatRelative(p.scheduledAt!),
                onTap: () => context.pushNamed(
                  RouteNames.postDetail,
                  pathParameters: {'id': p.id},
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _RemindersTab extends StatelessWidget {
  const _RemindersTab({required this.reminders});
  final List<Reminder> reminders;

  @override
  Widget build(BuildContext context) {
    if (reminders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: DashboardEmptyState(
          message: 'No upcoming reminders.',
          actionLabel: 'Manage',
          onAction: () => context.pushNamed(RouteNames.reminders),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: reminders
            .take(3)
            .map(
              (r) => DashboardListItem(
                icon: Icons.notifications_none_outlined,
                title: r.title,
                subtitle: AppDateUtils.formatRelative(r.scheduledAt),
                showChevron: false,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ActivityTab extends StatelessWidget {
  const _ActivityTab({required this.logs, required this.onCopyUrl});
  final List<PostingLog> logs;
  final void Function(BuildContext context, String url) onCopyUrl;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: DashboardEmptyState(
          message: 'No recent activity.',
          actionLabel: 'View logs',
          onAction: () => context.go('/logs'),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: logs
            .take(3)
            .map(
              (l) => DashboardActivityItem(
                log: l,
                onCopyUrl: onCopyUrl,
              ),
            )
            .toList(),
      ),
    );
  }
}