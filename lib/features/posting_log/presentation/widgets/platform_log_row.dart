import 'package:flutter/material.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../domain/entities/posting_log.dart';

/// Compact per-platform status summary shown above the detailed log list.
class PlatformLogRow extends StatelessWidget {
  const PlatformLogRow({
    super.key,
    required this.platforms,
    required this.logs,
  });

  final List<SocialPlatform> platforms;
  final List<PostingLog> logs;

  @override
  Widget build(BuildContext context) {
    if (platforms.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
        ),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: platforms.map((platform) {
          final status = _statusForPlatform(platform);
          return _PlatformStatusChip(platform: platform, status: status);
        }).toList(),
      ),
    );
  }

  LogStatus _statusForPlatform(SocialPlatform platform) {
    final platformLogs =
        logs.where((l) => l.platform == platform).toList();
    if (platformLogs.isEmpty) return LogStatus.pending;

    platformLogs.sort((a, b) {
      final aTime = a.postedAt ?? a.createdAt;
      final bTime = b.postedAt ?? b.createdAt;
      return bTime.compareTo(aTime);
    });
    return platformLogs.first.status;
  }
}

class _PlatformStatusChip extends StatelessWidget {
  const _PlatformStatusChip({
    required this.platform,
    required this.status,
  });

  final SocialPlatform platform;
  final LogStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(platform.icon, size: 16, color: platform.color),
        const SizedBox(width: 6),
        Text(
          platform.displayName,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: status.label,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: status.color.withValues(alpha: 0.45),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}