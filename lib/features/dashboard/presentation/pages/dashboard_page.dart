import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/widgets/theme_toggle_button.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../injection_container.dart';
import '../../../ai_prompts/presentation/cubit/ai_prompt_cubit.dart';
import '../../../ai_prompts/presentation/widgets/dashboard_ai_writer_card.dart';
import '../../../posting_log/domain/entities/posting_log.dart';
import '../../../posts/domain/entities/social_post.dart';
import '../../../reminders/domain/entities/reminder.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/dashboard_activity_item.dart';
import '../widgets/dashboard_list_item.dart';
import '../widgets/dashboard_section.dart';
import '../widgets/dashboard_stats_row.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<DashboardCubit>()..load()..startAutoRefresh(),
        ),
        BlocProvider(
          create: (_) => getIt<AiPromptCubit>(),
        ),
      ],
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    onPressed: () => context.read<DashboardCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<DashboardCubit>().load(),
              edgeOffset: 140,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _DashboardHeroWithStats(
                      isRefreshing: state.isRefreshing,
                      stats: state.stats,
                      onRefresh: () => context.read<DashboardCubit>().load(),
                      onOpenStudio: () {
                        final cubit = context.read<AiPromptCubit>();
                        cubit.flushPersist();
                        context.pushNamed(
                          RouteNames.aiPromptStudio,
                          extra: cubit,
                        );
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const _QuickActions(),
                        const SizedBox(height: 16),
                        const DashboardAiWriterCard(),
                        const SizedBox(height: 16),
                        _UpcomingPosts(posts: state.stats.upcomingPosts),
                        const SizedBox(height: 16),
                        _UpcomingReminders(
                          reminders: state.stats.upcomingReminders,
                        ),
                        const SizedBox(height: 16),
                        _RecentActivity(
                          logs: state.stats.recentActivity,
                          onCopyUrl: context.read<DashboardCubit>().copyLogUrl,
                        ),
                        const SizedBox(height: 16),
                        _PlatformBreakdown(
                          counts: state.stats.platformCounts,
                        ),
                        const SizedBox(height: 24),
                      ]),
                    ),
                  ),
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

class _DashboardHeroWithStats extends StatelessWidget {
  const _DashboardHeroWithStats({
    required this.isRefreshing,
    required this.stats,
    required this.onRefresh,
    required this.onOpenStudio,
  });

  final bool isRefreshing;
  final DashboardStats stats;
  final VoidCallback onRefresh;
  final VoidCallback onOpenStudio;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _DashboardHero(
          isRefreshing: isRefreshing,
          onRefresh: onRefresh,
          onOpenStudio: onOpenStudio,
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: -48,
          child: DashboardStatsRow(stats: stats),
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
    return DashboardSection(
      title: 'Upcoming Posts',
      icon: Icons.schedule_rounded,
      child: posts.isEmpty
          ? DashboardEmptyState(
              message: 'No scheduled posts yet.',
              actionLabel: 'Create a post',
              onAction: () => context.pushNamed(RouteNames.createPost),
            )
          : Column(
              children: posts
                  .map(
                    (p) => DashboardListItem(
                      icon: Icons.schedule_outlined,
                      iconColor: AppColors.statScheduled,
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

class _UpcomingReminders extends StatelessWidget {
  const _UpcomingReminders({required this.reminders});
  final List<Reminder> reminders;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      title: 'Upcoming Reminders',
      icon: Icons.notifications_active_rounded,
      child: reminders.isEmpty
          ? DashboardEmptyState(
              message: 'No upcoming reminders.',
              actionLabel: 'Manage reminders',
              onAction: () => context.pushNamed(RouteNames.reminders),
            )
          : Column(
              children: reminders
                  .map(
                    (r) => DashboardListItem(
                      icon: r.repeat.icon,
                      iconColor: r.repeat.color,
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

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.logs, required this.onCopyUrl});
  final List<PostingLog> logs;
  final void Function(BuildContext context, String url) onCopyUrl;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      title: 'Recent Activity',
      icon: Icons.history_rounded,
      trailing: logs.isNotEmpty
          ? TextButton(
              onPressed: () => context.go('/logs'),
              child: const Text('View all'),
            )
          : null,
      child: logs.isEmpty
          ? DashboardEmptyState(
              message: 'No recent activity.',
              actionLabel: 'View all logs',
              onAction: () => context.go('/logs'),
            )
          : Column(
              children: logs
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

class _PlatformBreakdown extends StatelessWidget {
  const _PlatformBreakdown({required this.counts});
  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    if (counts.isEmpty) return const SizedBox.shrink();
    final total = counts.values.fold<int>(0, (s, v) => s + v);
    final theme = Theme.of(context);

    return DashboardSection(
      title: 'Platform Mix',
      icon: Icons.pie_chart_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: counts.entries.map((e) {
          final plat = SocialPlatformX.fromName(e.key) ?? SocialPlatform.twitter;
          final pct = total == 0 ? 0.0 : e.value / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: AppDecorations.iconBadge(plat.color),
                      child: Icon(plat.icon, color: plat.color, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      plat.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      '${e.value}',
                      style: AppTextStyles.subtitle.copyWith(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      ' · ${(pct * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.caption.copyWith(
                        color: theme.hintColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(8),
                    backgroundColor:
                        theme.dividerColor.withValues(alpha: 0.2),
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

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.isRefreshing,
    required this.onRefresh,
    required this.onOpenStudio,
  });

  final bool isRefreshing;
  final VoidCallback onRefresh;
  final VoidCallback onOpenStudio;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppThemeTokens>() ??
        AppThemeTokens.light();
    final topPad = MediaQuery.paddingOf(context).top;
    final greeting = _greetingForTime();

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: tokens.heroGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: AppDecorations.heroOrb(Colors.white, opacity: 0.08),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: AppDecorations.heroOrb(
                AppColors.secondaryLight,
                opacity: 0.15,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 72),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: AppTextStyles.heroGreeting(context),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'SocialBox',
                            style: AppTextStyles.heroTitle(context),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your content command center',
                            style: AppTextStyles.onGradient(context),
                          ),
                        ],
                      ),
                    ),
                    _HeroIconButton(
                      tooltip: 'Toggle theme',
                      decoration: AppDecorations.glassButton(),
                      child: const ThemeToggleButton(iconColor: Colors.white),
                    ),
                    if (isRefreshing)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      _HeroIconButton(
                        tooltip: 'Refresh',
                        icon: Icons.refresh_rounded,
                        onPressed: onRefresh,
                      ),
                    _HeroIconButton(
                      tooltip: 'AI Writer',
                      icon: Icons.auto_awesome_rounded,
                      onPressed: onOpenStudio,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _greetingForTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({
    required this.tooltip,
    this.icon,
    this.onPressed,
    this.child,
    this.decoration,
  });

  final String tooltip;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Widget? child;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              width: 40,
              height: 40,
              decoration: decoration ?? AppDecorations.glassButton(),
              child: child ??
                  Icon(icon, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.add_circle_outline_rounded,
            label: 'New Post',
            subtitle: 'Create manually',
            accentColor: AppColors.statScheduled,
            onTap: () => context.pushNamed(RouteNames.createPost),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.calendar_today_rounded,
            label: 'Calendar',
            subtitle: 'Schedule view',
            accentColor: AppColors.accentViolet,
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
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: AppDecorations.surfaceCard(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: AppDecorations.iconBadge(accentColor),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}