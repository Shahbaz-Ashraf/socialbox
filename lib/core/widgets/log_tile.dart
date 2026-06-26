import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/posting_log/domain/entities/posting_log.dart';
import '../utils/date_utils.dart';
import '../utils/platform_utils.dart';

class LogTile extends StatelessWidget {
  const LogTile({
    super.key,
    required this.log,
    this.onStatusChanged,
    this.onCopyUrl,
  });

  final PostingLog log;
  final ValueChanged<LogStatus>? onStatusChanged;
  final void Function(BuildContext context, String url)? onCopyUrl;

  @override
  Widget build(BuildContext context) {
    final time = log.postedAt ?? log.createdAt;
    return GestureDetector(
      onLongPress:
          onStatusChanged == null ? null : () => _showStatusMenu(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final narrow = constraints.maxWidth < 260;
                      final platformName = Text(
                        log.platform.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                      final statusBadge = GestureDetector(
                        onTap: onStatusChanged == null
                            ? null
                            : () => _showStatusMenu(context),
                        child: Container(
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
                              if (onStatusChanged != null) ...[
                                const SizedBox(width: 2),
                                Icon(Icons.arrow_drop_down_rounded,
                                    size: 14, color: log.status.color),
                              ],
                            ],
                          ),
                        ),
                      );
                      final methodLabel = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(log.method.icon,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              log.method.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                            ),
                          ),
                        ],
                      );

                      if (narrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(child: platformName),
                                const SizedBox(width: 8),
                                statusBadge,
                              ],
                            ),
                            const SizedBox(height: 4),
                            methodLabel,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Flexible(child: platformName),
                          const SizedBox(width: 8),
                          statusBadge,
                          const SizedBox(width: 6),
                          Flexible(child: methodLabel),
                        ],
                      );
                    },
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
            if (onStatusChanged != null)
              PopupMenuButton<LogStatus>(
                tooltip: 'Change status',
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: onStatusChanged,
                itemBuilder: (_) => LogStatus.values
                    .map(
                      (s) => PopupMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            Icon(s.icon, size: 18, color: s.color),
                            const SizedBox(width: 8),
                            Text(s.label),
                            if (s == log.status) ...[
                              const Spacer(),
                              const Icon(Icons.check_rounded, size: 16),
                            ],
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            if (log.externalPostUrl != null && onCopyUrl != null) ...[
              IconButton(
                tooltip: 'Copy URL',
                icon: const Icon(Icons.link_rounded),
                onPressed: () => onCopyUrl!(context, log.externalPostUrl!),
              ),
              IconButton(
                tooltip: 'Open post',
                icon: const Icon(Icons.open_in_new_rounded),
                onPressed: () =>
                    launchUrl(Uri.parse(log.externalPostUrl!)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showStatusMenu(BuildContext context) async {
    final handler = onStatusChanged;
    if (handler == null) return;
    final selected = await showModalBottomSheet<LogStatus>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Update log status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            ...LogStatus.values.map(
              (s) => ListTile(
                leading: Icon(s.icon, color: s.color),
                title: Text(s.label),
                trailing:
                    s == log.status ? const Icon(Icons.check_rounded) : null,
                onTap: () => Navigator.pop(context, s),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (selected != null && selected != log.status) {
      handler(selected);
    }
  }
}