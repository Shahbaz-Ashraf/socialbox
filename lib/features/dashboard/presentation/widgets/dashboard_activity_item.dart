import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../posting_log/domain/entities/posting_log.dart';

class DashboardActivityItem extends StatelessWidget {
  const DashboardActivityItem({
    super.key,
    required this.log,
    required this.onCopyUrl,
  });

  final PostingLog log;
  final void Function(BuildContext context, String url) onCopyUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = log.postedAt ?? log.createdAt;
    final platform = log.platform;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: log.externalPostUrl != null
              ? () => launchUrl(Uri.parse(log.externalPostUrl!))
              : null,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: AppDecorations.listItemSurface(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: AppDecorations.iconBadge(platform.color),
                    child: Icon(platform.icon, size: 18, color: platform.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                platform.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.subtitle.copyWith(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            _StatusPill(status: log.status),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          AppDateUtils.formatRelative(time),
                          style: AppTextStyles.caption.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (log.externalPostUrl != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: 'Copy link',
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.link_rounded,
                        size: 18,
                        color: theme.hintColor,
                      ),
                      onPressed: () =>
                          onCopyUrl(context, log.externalPostUrl!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final LogStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: status.color,
        ),
      ),
    );
  }
}