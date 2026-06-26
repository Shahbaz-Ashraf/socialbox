import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../injection_container.dart';
import '../../../ai_prompts/domain/entities/prompt_config.dart';
import '../../../posting_log/presentation/cubit/log_cubit.dart';
import '../../../posting_log/presentation/widgets/log_tile.dart';
import '../../domain/entities/social_post.dart';
import '../../domain/usecases/post_usecases.dart';
import '../widgets/post_status_badge.dart';

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({super.key, required this.postId});
  final String postId;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  SocialPost? _post;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await getIt<GetPostById>().call(widget.postId);
    if (!mounted) return;
    r.fold(
      (f) => setState(() {
        _loading = false;
        _post = null;
      }),
      (p) => setState(() {
        _post = p;
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    final post = _post;
    if (post == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Post not found')),
      );
    }

    return BlocProvider(
      create: (_) => LogCubit(
        repository: getIt(),
      )..loadForPost(widget.postId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Post Detail'),
          actions: [
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
                  pathParameters: {'id': widget.postId},
                );
                if (mounted) _load();
              },
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(post.title,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800)),
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
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.4)),
              ),
              child: Text(post.content,
                  style: const TextStyle(fontSize: 15, height: 1.5)),
            ),
            const SizedBox(height: 16),
            const Text('Platforms',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: post.platforms
                  .map((p) => _PlatformActionButton(
                        platform: p,
                        onOpen: () => launchUrl(Uri.parse(p.webUrl)),
                        onMarkPosted: () => _markPosted(context, p),
                      ))
                  .toList(),
            ),
            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Tags', style: TextStyle(fontWeight: FontWeight.w700)),
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
              const Text('Notes',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(post.notes!),
            ],
            const SizedBox(height: 24),
            const Text('Posting Log',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            BlocBuilder<LogCubit, LogState>(
              builder: (context, logState) {
                if (logState is LogLoaded) {
                  if (logState.logs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No log entries yet.'),
                    );
                  }
                  return Column(
                    children: logState.logs
                        .map((l) => LogTile(log: l))
                        .toList(),
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
      ),
    );
  }

  Future<void> _markPosted(BuildContext context, SocialPlatform platform) async {
    final notesCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Mark as posted on ${platform.displayName}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'This will record a manual log entry for this post on ${platform.displayName}.'),
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
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Mark Posted')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    HapticFeedback.mediumImpact();
    final result = await getIt<MarkPostedManually>().call(
      MarkPostedManuallyParams(
        postId: widget.postId,
        platform: platform,
        notes: notesCtrl.text.isEmpty ? null : notesCtrl.text,
      ),
    );
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Marked as posted on ${platform.displayName}')),
        );
        _load();
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Post?'),
        content: const Text('This post and its logs will be permanently deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton.tonal(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final r = await getIt<DeletePost>().call(widget.postId);
    r.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (_) {
        if (context.mounted) context.pop();
      },
    );
  }
}

class _PlatformActionButton extends StatelessWidget {
  const _PlatformActionButton({
    required this.platform,
    required this.onOpen,
    required this.onMarkPosted,
  });

  final SocialPlatform platform;
  final VoidCallback onOpen;
  final VoidCallback onMarkPosted;

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
          Text(platform.displayName,
              style: TextStyle(
                  color: platform.color, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Open ${platform.displayName}',
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.open_in_new_rounded, size: 16, color: platform.color),
            onPressed: onOpen,
          ),
          IconButton(
            tooltip: 'Mark as posted',
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.check_circle_outline_rounded,
                size: 18, color: platform.color),
            onPressed: onMarkPosted,
          ),
        ],
      ),
    );
  }
}
