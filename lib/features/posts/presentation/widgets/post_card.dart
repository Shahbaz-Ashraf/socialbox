import 'package:flutter/material.dart';

import '../../../../core/services/clipboard_service.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/social_post.dart';
import 'post_status_badge.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, this.onTap});

  final SocialPost post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      post.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy content',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    onPressed: () => getIt<ClipboardService>().copyText(
                      context,
                      post.content,
                    ),
                  ),
                  PostStatusBadge(status: post.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: post.platforms
                    .map((p) => _PlatformPill(platform: p))
                    .toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (post.scheduledAt != null) ...[
                    const Icon(Icons.schedule_rounded, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      AppDateUtils.formatRelative(post.scheduledAt!),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (post.isRecurring) ...[
                    const Icon(Icons.repeat_rounded, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      post.recurringType.label,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                  const Spacer(),
                  if (post.tags.isNotEmpty)
                    Text(
                      '${post.tags.length} tag${post.tags.length == 1 ? '' : 's'}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatformPill extends StatelessWidget {
  const _PlatformPill({required this.platform});
  final SocialPlatform platform;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: platform.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(platform.icon, size: 12, color: platform.color),
          const SizedBox(width: 4),
          Text(
            platform.shortName,
            style: TextStyle(
              color: platform.color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}