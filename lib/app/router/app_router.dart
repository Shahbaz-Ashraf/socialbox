import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/main_shell.dart';
import '../../features/ai_prompts/domain/entities/ai_post_prefill.dart';
import '../../features/ai_prompts/domain/entities/prompt_config.dart';
import '../../features/ai_prompts/presentation/pages/ai_prompt_studio_page.dart';
import '../../features/comment_templates/presentation/pages/categories_page.dart';
import '../../features/comment_templates/presentation/pages/comments_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/posting_log/presentation/pages/post_log_detail_page.dart';
import '../../features/posting_log/presentation/pages/posting_log_page.dart';
import '../../features/posts/presentation/pages/calendar_page.dart';
import '../../features/posts/presentation/pages/create_edit_post_page.dart';
import '../../features/posts/presentation/pages/post_detail_page.dart';
import '../../features/posts/presentation/pages/posts_page.dart';
import '../../features/reminders/presentation/pages/reminders_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/social_auth/presentation/pages/social_accounts_page.dart';
import 'route_names.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          name: RouteNames.dashboard,
          builder: (_, __) => const DashboardPage(),
        ),
        GoRoute(
          path: '/ai-writer',
          name: RouteNames.aiPromptStudio,
          builder: (_, state) {
            final extra = state.extra;
            if (extra is PromptConfig) {
              return AiPromptStudioPage(initialConfig: extra);
            }
            final qp = state.uri.queryParameters;
            PromptConfig? initial;
            if (qp.containsKey('topic')) {
              initial = PromptConfig.fromPost(
                title: qp['topic'] ?? '',
                tags: qp['tags']
                    ?.split(',')
                    .where((t) => t.isNotEmpty)
                    .toList(),
              );
              if (qp['platform'] != null) {
                initial = initial.copyWith(
                  platform: PromptConfig.normalizePlatform(qp['platform']!),
                );
              }
            }
            return AiPromptStudioPage(initialConfig: initial);
          },
        ),
        GoRoute(
          path: '/calendar',
          name: RouteNames.calendar,
          builder: (_, __) => const CalendarPage(),
        ),
        GoRoute(
          path: '/comments',
          name: RouteNames.categories,
          builder: (_, __) => const CategoriesPage(),
          routes: [
            GoRoute(
              path: ':categoryId',
              name: RouteNames.comments,
              builder: (_, state) => CommentsPage(
                categoryId: state.pathParameters['categoryId']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/posts',
          name: RouteNames.posts,
          builder: (_, __) => const PostsPage(),
          routes: [
            GoRoute(
              path: 'new',
              name: RouteNames.createPost,
              builder: (_, state) {
                final prefill = state.uri.queryParameters['prefillDate'];
                final extra = state.extra;
                return CreateEditPostPage(
                  prefillDate: _parseDate(prefill),
                  aiPrefill: extra is AiPostPrefill ? extra : null,
                );
              },
            ),
            GoRoute(
              path: ':id',
              name: RouteNames.postDetail,
              builder: (_, state) =>
                  PostDetailPage(postId: state.pathParameters['id']!),
              routes: [
                GoRoute(
                  path: 'edit',
                  name: RouteNames.editPost,
                  builder: (_, state) => CreateEditPostPage(
                    postId: state.pathParameters['id'],
                  ),
                ),
                GoRoute(
                  path: 'logs',
                  name: RouteNames.postLogs,
                  builder: (_, state) => PostLogDetailPage(
                    postId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/logs',
          name: RouteNames.logs,
          builder: (_, __) => const PostingLogPage(),
        ),
        GoRoute(
          path: '/settings',
          name: RouteNames.settings,
          builder: (_, __) => const SettingsPage(),
          routes: [
            GoRoute(
              path: 'accounts',
              name: RouteNames.socialAccounts,
              builder: (_, __) => const SocialAccountsPage(),
            ),
            GoRoute(
              path: 'reminders',
              name: RouteNames.reminders,
              builder: (_, state) {
                final extra = state.extra;
                if (extra is Map<String, dynamic>) {
                  return RemindersPage(
                    prefillTitle: extra['prefillTitle'] as String?,
                    prefillTime: extra['prefillTime'] as DateTime?,
                    postId: extra['postId'] as String?,
                    autoOpenForm: true,
                  );
                }
                return const RemindersPage();
              },
            ),
            GoRoute(
              path: 'ai-writer',
              redirect: (_, __) => '/ai-writer',
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (_, state) => Scaffold(
    appBar: AppBar(title: const Text('Not Found')),
    body: Center(child: Text('No route for ${state.uri}')),
  ),
);

DateTime? _parseDate(String? raw) {
  if (raw == null) return null;
  return DateTime.tryParse(raw);
}
