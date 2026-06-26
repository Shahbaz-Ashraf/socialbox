import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../injection_container.dart';
import '../../../posts/domain/entities/social_post.dart';
import '../../../posting_log/presentation/widgets/log_tile.dart';
import '../../../reminders/domain/entities/reminder.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../../ai_prompts/presentation/widgets/dashboard_ai_writer_card.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/stat_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardCubit>()..load()..startAutoRefresh(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SocialBox'),
        actions: [
          IconButton(
            tooltip: 'AI Post Writer',
            icon: const Icon(Icons.psychology_rounded),
            onPressed: () => context.pushNamed(RouteNames.aiPromptStudio),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<DashboardCubit>().load(),
          ),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardInitial || state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<DashboardCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<DashboardCubit>().load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const DashboardAiWriterCard(),
                  const SizedBox(height: 12),
                  _QuickActions(),
                  const SizedBox(height: 16),
                  _StatGrid(stats: state.stats),
                  const SizedBox(height: 20),
                  _UpcomingPosts(posts: state.stats.upcomingPosts),
                  const SizedBox(height: 20),
                  _UpcomingReminders(reminders: state.stats.upcomingReminders),
                  const SizedBox(height: 20),
                  _RecentActivity(logs: state.stats.recentActivity),
                  const SizedBox(height: 24),
                  _PlatformBreakdown(counts: state.stats.platformCounts),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});
  final DashboardStats stats;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = width > 600 ? 4 : 2;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: cols,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.2,
      children: [
        StatCard(
          label: 'Total Posts',
          value: '${stats.totalPosts}',
          icon: Icons.article_rounded,
          color: const Color(0xFF6750A4),
        ),
        StatCard(
          label: 'Scheduled',
          value: '${stats.scheduledPosts}',
          icon: Icons.schedule_rounded,
          color: const Color(0xFF2196F3),
        ),
        StatCard(
          label: 'Posted',
          value: '${stats.postedPosts}',
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF4CAF50),
        ),
        StatCard(
          label: 'Drafts',
          value: '${stats.draftPosts}',
          icon: Icons.edit_note_rounded,
          color: const Color(0xFF607D8B),
        ),
        StatCard(
          label: 'Comments',
          value: '${stats.totalComments}',
          icon: Icons.chat_bubble_rounded,
          color: const Color(0xFFFF9800),
        ),
        StatCard(
          label: 'Categories',
          value: '${stats.totalCommentCategories}',
          icon: Icons.folder_rounded,
          color: const Color(0xFF9C27B0),
        ),
        StatCard(
          label: 'Copies',
          value: '${stats.totalCopies}',
          icon: Icons.content_copy_rounded,
          color: const Color(0xFFE91E63),
        ),
        StatCard(
          label: 'Log Entries',
          value: '${stats.totalLogs}',
          icon: Icons.history_rounded,
          color: const Color(0xFF00BCD4),
        ),
      ],
    );
  }
}

class _UpcomingPosts extends StatelessWidget {
  const _UpcomingPosts({required this.posts});
  final List<SocialPost> posts;
  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Upcoming Posts',
      icon: Icons.schedule_rounded,
      child: posts.isEmpty
          ? const _EmptyHint('No scheduled posts yet.')
          : Column(
              children: posts
                  .map((p) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.schedule_rounded),
                        title: Text(p.title,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          AppDateUtils.formatRelative(p.scheduledAt!),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.pushNamed(
                          RouteNames.postDetail,
                          pathParameters: {'id': p.id},
                        ),
                      ))
                  .toList(),
            ),
    );
  }
}

class _UpcomingReminders extends StatelessWidget {
  const _UpcomingReminders({required this.reminders});
  final List<Reminder> reminders;
  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Upcoming Reminders',
      icon: Icons.notifications_active_rounded,
      child: reminders.isEmpty
          ? const _EmptyHint('No upcoming reminders.')
          : Column(
              children: reminders
                  .map((r) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(r.repeat.icon, color: r.repeat.color),
                        title: Text(r.title,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle:
                            Text(AppDateUtils.formatRelative(r.scheduledAt)),
                      ))
                  .toList(),
            ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.logs});
  final List logs;
  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Recent Activity',
      icon: Icons.history_rounded,
      child: logs.isEmpty
          ? const _EmptyHint('No recent activity.')
          : Column(
              children:
                  logs.map<Widget>((l) => LogTile(log: l)).toList(),
            ),
    );
  }
}

class _PlatformBreakdown extends StatelessWidget {
  const _PlatformBreakdown({required this.counts});
  final Map<String, int> counts;
  @override
  Widget build(BuildContext context) {
    if (counts.isEmpty) return const SizedBox.shrink();
    final total = counts.values.fold<int>(0, (s, v) => s + v);
    return _Section(
      title: 'Platform Mix',
      icon: Icons.donut_large_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: counts.entries.map((e) {
          final plat = SocialPlatformX.fromName(e.key) ?? SocialPlatform.twitter;
          final pct = total == 0 ? 0.0 : e.value / total;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(plat.icon, color: plat.color, size: 16),
                    const SizedBox(width: 6),
                    Text(plat.displayName,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('${e.value} (${(pct * 100).toStringAsFixed(0)}%)',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor:
                        Theme.of(context).dividerColor.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation(plat.color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.add_circle_outline_rounded,
            label: 'New Post',
            subtitle: 'Create manually',
            color: const Color(0xFF2196F3),
            onTap: () => context.pushNamed(RouteNames.createPost),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionCard(
            icon: Icons.calendar_today_rounded,
            label: 'Calendar',
            subtitle: 'Schedule view',
            color: const Color(0xFF6750A4),
            onTap: () => context.go('/calendar'),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: color)),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).hintColor)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text,
          style:
              TextStyle(color: Theme.of(context).hintColor, fontSize: 13)),
    );
  }
}
