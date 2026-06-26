import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../domain/entities/posting_log.dart';

class LogTile extends StatelessWidget {
  const LogTile({super.key, required this.log});

  final PostingLog log;

  @override
  Widget build(BuildContext context) {
    final time = log.postedAt ?? log.createdAt;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: log.platform.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(log.platform.icon, color: log.platform.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      log.platform.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: log.status.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(log.status.icon,
                              size: 12, color: log.status.color),
                          const SizedBox(width: 4),
                          Text(log.status.label,
                              style: TextStyle(
                                  color: log.status.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(log.method.icon,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 2),
                        Text(log.method.label,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  AppDateUtils.formatDateTime(time),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if ((log.notes ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(log.notes!,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
                if ((log.errorMessage ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Error: ${log.errorMessage!}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.redAccent)),
                ],
              ],
            ),
          ),
          if (log.externalPostUrl != null)
            IconButton(
              tooltip: 'Open post',
              icon: const Icon(Icons.open_in_new_rounded),
              onPressed: () =>
                  launchUrl(Uri.parse(log.externalPostUrl!)),
            ),
        ],
      ),
    );
  }
}
