import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.45);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: log.externalPostUrl != null
              ? () => launchUrl(Uri.parse(log.externalPostUrl!))
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Row(
              children: [
                Icon(platform.icon, size: 18, color: muted),
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
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Text(
                            log.status.label,
                            style: AppTextStyles.caption.copyWith(
                              color: muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppDateUtils.formatRelative(time),
                        style: AppTextStyles.caption.copyWith(color: muted),
                      ),
                    ],
                  ),
                ),
                if (log.externalPostUrl != null)
                  IconButton(
                    tooltip: 'Copy link',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.link_rounded, size: 18, color: muted),
                    onPressed: () => onCopyUrl(context, log.externalPostUrl!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}