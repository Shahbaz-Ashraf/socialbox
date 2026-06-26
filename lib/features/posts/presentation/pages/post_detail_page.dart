import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/services/clipboard_service.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../injection_container.dart';
import '../../../ai_prompts/domain/entities/prompt_config.dart';
import '../../../posting_log/presentation/cubit/log_cubit.dart';
import '../../../../core/widgets/log_tile.dart';
import '../../../posting_log/presentation/widgets/platform_log_row.dart';
import '../cubit/post_detail_cubit.dart';
import '../widgets/post_status_badge.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key, required this.postId});
  final String postId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<PostDetailCubit>(param1: postId)..load(),
        ),
        BlocProvider(
          create: (_) => LogCubit(
            repository: getIt(),
            updateLogStatus: getIt(),
          )..loadForPost(postId),
        ),
      ],
      child: _PostDetailView(postId: postId),
    );
  }
}

class _PostDetailView extends StatelessWidget {
  const _PostDetailView({required this.postId});
  final String postId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostDetailCubit, PostDetailState>(
      builder: (context, state) {
        if (state is PostDetailLoading || state is PostDetailInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is PostDetailNotFound) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Post not found')),
          );
        }
        if (state is PostDetailError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(state.message)),
          );
        }

        final post = switch (state) {
          PostDetailLoaded(:final post) => post,
          PostDetailActionInProgress(:final post) => post,
          _ => null,
        };
        if (post == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isBusy = state is PostDetailActionInProgress;
        final cubit = context.read<PostDetailCubit>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Post Detail'),
            actions: [
              IconButton(
                tooltip: 'Copy post',
                icon: const Icon(Icons.copy_rounded),
                onPressed: () => getIt<ClipboardService>().copyText(
                  context,
                  '${post.title}\n\n${post.content}',
                ),
              ),
              IconButton(
                tooltip: 'Duplicate post',
                icon: const Icon(Icons.content_copy_rounded),
                onPressed: isBusy ? null : () => _duplicate(context, cubit),
              ),
              IconButton(
                tooltip: 'View logs',
                icon: const Icon(Icons.history_rounded),
                onPressed: () => context.pushNamed(
                  RouteNames.postLogs,
                  pathParameters: {'id': postId},
                ),
              ),
              IconButton(
                tooltip: 'AI Post Writer',
                icon: const Icon(Icons.psychology_rounded),
                onPressed: () {
                  context.pushNamed(
                    RouteNames.aiPromptStudio,
                    extra: PromptConfig.fromPost(
                      title: post.title,
                      content: post.content,
                      platforms: post.platforms,
                      tags: post.tags,
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_rounded),
                onPressed: () async {
                  await context.pushNamed(
                    RouteNames.editPost,
                    pathParameters: {'id': postId},
                  );
                  if (context.mounted) cubit.load();
                },
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: isBusy ? null : () => _confirmDelete(context, cubit),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  PostStatusBadge(status: post.status),
                ],
              ),
              if (post.scheduledAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 16),
                    const SizedBox(width: 4),
                    Text(AppDateUtils.formatDateTime(post.scheduledAt!)),
                    const SizedBox(width: 8),
                    Text(
                      '(${AppDateUtils.formatRelative(post.scheduledAt!)})',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context)
                        .dividerColor
                        .withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  post.content,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Platforms',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: post.platforms
                    .map(
                      (p) => _PlatformActionButton(
                        platform: p,
                        onOpen: () => launchUrl(Uri.parse(p.webUrl)),
                        onPublishViaApi: isBusy
                            ? null
                            : () => _publishViaApi(context, cubit, p),
                        onMarkPosted: isBusy
                            ? null
                            : () => _markPosted(context, cubit, p),
                      ),
                    )
                    .toList(),
              ),
              if (post.tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Tags',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: post.tags
                      .map((t) => Chip(label: Text('#$t')))
                      .toList(),
                ),
              ],
              if ((post.notes ?? '').isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Notes',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(post.notes!),
              ],
              const SizedBox(height: 24),
              const Text(
                'Posting Log',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              BlocBuilder<LogCubit, LogState>(
                builder: (context, logState) {
                  if (logState is LogLoaded) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PlatformLogRow(
                          platforms: post.platforms,
                          logs: logState.logs,
                        ),
                        const SizedBox(height: 12),
                        if (logState.logs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('No log entries yet.'),
                          )
                        else
                          ...logState.logs.map(
                            (l) => LogTile(
                              log: l,
                              onStatusChanged: (status) async {
                                final ok = await context
                                    .read<LogCubit>()
                                    .changeStatus(l.id, status);
                                if (!context.mounted) return;
                                if (ok) {
                                  AppSnackbar.success(
                                    context,
                                    'Status updated to ${status.label}',
                                  );
                                } else {
                                  AppSnackbar.error(
                                    context,
                                    'Could not update status',
                                  );
                                }
                              },
                            ),
                          ),
                      ],
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _duplicate(
      BuildContext context, PostDetailCubit cubit) async {
    final newId = await cubit.duplicate();
    if (!context.mounted) return;
    if (newId != null) {
      AppSnackbar.success(context, 'Post duplicated');
      context.pushNamed(
        RouteNames.postDetail,
        pathParameters: {'id': newId},
      );
    } else {
      AppSnackbar.error(context, 'Could not duplicate post');
    }
  }

  Future<void> _publishViaApi(
    BuildContext context,
    PostDetailCubit cubit,
    SocialPlatform platform,
  ) async {
    HapticFeedback.lightImpact();
    final message = await cubit.publishViaApi(platform: platform);
    if (!context.mounted) return;
    if (message != null) {
      AppSnackbar.info(context, message);
    } else {
      AppSnackbar.success(
        context,
        'Published to ${platform.displayName}',
      );
      context.read<LogCubit>().loadForPost(postId);
    }
  }

  Future<void> _markPosted(
    BuildContext context,
    PostDetailCubit cubit,
    SocialPlatform platform,
  ) async {
    final notesCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Mark as posted on ${platform.displayName}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This will record a manual log entry for this post on ${platform.displayName}.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mark Posted'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    HapticFeedback.mediumImpact();
    final success = await cubit.markPosted(
      platform: platform,
      notes: notesCtrl.text.isEmpty ? null : notesCtrl.text,
    );
    if (!context.mounted) return;
    if (success) {
      AppSnackbar.success(
        context,
        'Marked as posted on ${platform.displayName}',
      );
      context.read<LogCubit>().loadForPost(postId);
    } else {
      AppSnackbar.error(context, 'Could not mark as posted');
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, PostDetailCubit cubit) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Post?'),
        content: const Text(
          'This post and its logs will be permanently deleted.',
        ),
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
    final deleted = await cubit.deletePost();
    if (!context.mounted) return;
    if (deleted) {
      context.pop();
    } else {
      AppSnackbar.error(context, 'Could not delete post');
    }
  }
}

class _PlatformActionButton extends StatelessWidget {
  const _PlatformActionButton({
    required this.platform,
    required this.onOpen,
    this.onPublishViaApi,
    required this.onMarkPosted,
  });

  final SocialPlatform platform;
  final VoidCallback onOpen;
  final VoidCallback? onPublishViaApi;
  final VoidCallback? onMarkPosted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: platform.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: platform.color.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(platform.icon, size: 18, color: platform.color),
          const SizedBox(width: 6),
          Text(
            platform.displayName,
            style: TextStyle(
              color: platform.color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Open ${platform.displayName}',
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.open_in_new_rounded,
              size: 16,
              color: platform.color,
            ),
            onPressed: onOpen,
          ),
          if (onPublishViaApi != null)
            IconButton(
              tooltip: 'Publish via API',
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.cloud_upload_rounded,
                size: 18,
                color: platform.color,
              ),
              onPressed: onPublishViaApi,
            ),
          IconButton(
            tooltip: 'Mark as posted',
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.check_circle_outline_rounded,
              size: 18,
              color: platform.color,
            ),
            onPressed: onMarkPosted,
          ),
        ],
      ),
    );
  }
}