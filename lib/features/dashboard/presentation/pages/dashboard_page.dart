import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/widgets/theme_toggle_button.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../injection_container.dart';
import '../../../comment_templates/domain/usecases/comment_usecases.dart';
import '../../../ai_prompts/presentation/cubit/ai_prompt_cubit.dart';
import '../../../ai_prompts/presentation/widgets/dashboard_ai_writer_card.dart';
import '../../../posts/domain/entities/social_post.dart';
import '../../../posts/domain/usecases/post_usecases.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/dashboard_feed_tabs.dart';
import '../widgets/dashboard_stats_row.dart';
import '../widgets/global_search_delegate.dart';

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
                  FilledButton(
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
              edgeOffset: kToolbarHeight,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    elevation: 0,
                    scrolledUnderElevation: 0.5,
                    backgroundColor:
                        Theme.of(context).scaffoldBackgroundColor,
                    surfaceTintColor: Colors.transparent,
                    title: _DashboardTitle(isRefreshing: state.isRefreshing),
                    actions: [
                      _DashboardToolbar(
                        isRefreshing: state.isRefreshing,
                        onRefresh: () => context.read<DashboardCubit>().load(),
                        onOpenStudio: () {
                          final cubit = context.read<AiPromptCubit>();
                          cubit.flushPersist();
                          context.pushNamed(
                            RouteNames.aiPromptStudio,
                            extra: cubit,
                          );
                        },
                        onSearch: () => _DashboardToolbar.openGlobalSearch(
                          context,
                        ),
                      ),
                    ],
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const DashboardAiWriterCard(),
                        const SizedBox(height: 12),
                        DashboardStatsRow(stats: state.stats),
                        const SizedBox(height: 12),
                        const _QuickActions(),
                        const SizedBox(height: 12),
                        DashboardFeedTabs(
                          posts: state.stats.upcomingPosts,
                          reminders: state.stats.upcomingReminders,
                          logs: state.stats.recentActivity,
                          onCopyUrl:
                              context.read<DashboardCubit>().copyLogUrl,
                        ),
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

class _DashboardTitle extends StatelessWidget {
  const _DashboardTitle({required this.isRefreshing});

  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: AppDecorations.accentHeader(context),
          child: Icon(
            Icons.dashboard_rounded,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Home',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                isRefreshing ? 'Syncing…' : 'Your content hub',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardToolbar extends StatelessWidget {
  const _DashboardToolbar({
    required this.isRefreshing,
    required this.onRefresh,
    required this.onOpenStudio,
    required this.onSearch,
  });

  final bool isRefreshing;
  final VoidCallback onRefresh;
  final VoidCallback onOpenStudio;
  final VoidCallback onSearch;

  static void openGlobalSearch(BuildContext context) {
    final getAllPosts = getIt<GetAllPosts>();
    final searchComments = getIt<SearchComments>();

    showSearch(
      context: context,
      delegate: GlobalSearchDelegate(
        searchPosts: (query) async {
          final result = await getAllPosts(const NoParams());
          return result.fold((_) => const <SocialPost>[], (posts) {
            final q = query.toLowerCase();
            return posts
                .where(
                  (p) =>
                      p.title.toLowerCase().contains(q) ||
                      p.content.toLowerCase().contains(q),
                )
                .toList();
          });
        },
        searchComments: (query) async {
          final result = await searchComments(query);
          return result.fold((_) => const [], (comments) => comments);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 400;

    if (narrow) {
      return PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert_rounded),
        onSelected: (value) => switch (value) {
          'search' => onSearch(),
          'refresh' => onRefresh(),
          'ai' => onOpenStudio(),
          _ => null,
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'search', child: Text('Search')),
          PopupMenuItem(
            value: 'refresh',
            enabled: !isRefreshing,
            child: Text(isRefreshing ? 'Syncing…' : 'Refresh'),
          ),
          const PopupMenuItem(value: 'ai', child: Text('AI Studio')),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Search',
          icon: const Icon(Icons.search_rounded),
          onPressed: onSearch,
        ),
        const ThemeToggleButton(),
        if (isRefreshing)
          const Padding(
            padding: EdgeInsets.all(12),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: onRefresh,
          ),
        IconButton(
          tooltip: 'AI Studio',
          icon: const Icon(Icons.auto_awesome_outlined),
          onPressed: onOpenStudio,
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ActionChip(
          icon: Icons.add_rounded,
          label: 'New post',
          onTap: () => context.pushNamed(RouteNames.createPost),
        ),
        _ActionChip(
          icon: Icons.calendar_today_rounded,
          label: 'Calendar',
          onTap: () => context.go('/calendar'),
        ),
        _ActionChip(
          icon: Icons.history_rounded,
          label: 'Logs',
          onTap: () => context.go('/logs'),
        ),
        _ActionChip(
          icon: Icons.send_rounded,
          label: 'Posts',
          onTap: () => context.go('/posts'),
          outlined: true,
        ),
        Text(
          'Swipe metrics for more',
          style: AppTextStyles.caption.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 6),
        Text(label),
      ],
    );

    if (outlined) {
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: child,
      );
    }

    return FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: child,
    );
  }
}