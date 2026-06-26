import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/dashboard_stats.dart';
import 'stat_card.dart';

class DashboardStatsRow extends StatelessWidget {
  const DashboardStatsRow({super.key, required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = [
      _StatDef('Posts', '${stats.totalPosts}', Icons.article_outlined,
          AppColors.statPosts),
      _StatDef('Scheduled', '${stats.scheduledPosts}', Icons.schedule_outlined,
          AppColors.statScheduled),
      _StatDef('Posted', '${stats.postedPosts}', Icons.check_circle_outline,
          AppColors.statPosted),
      _StatDef('Drafts', '${stats.draftPosts}', Icons.edit_note_outlined,
          AppColors.statDrafts),
      _StatDef('Comments', '${stats.totalComments}',
          Icons.chat_bubble_outline_rounded, AppColors.statComments),
      _StatDef('Copies', '${stats.totalCopies}', Icons.content_copy_outlined,
          AppColors.statCopies),
      _StatDef('Categories', '${stats.totalCommentCategories}',
          Icons.folder_outlined, AppColors.statCategories),
      _StatDef('Logs', '${stats.totalLogs}', Icons.history_rounded,
          AppColors.statLogs),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Metrics', style: AppTextStyles.sectionHeader(context)),
        const SizedBox(height: 8),
        SizedBox(
          height: 68,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: metrics.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final s = metrics[i];
              return StatCard(
                label: s.label,
                value: s.value,
                icon: s.icon,
                color: s.color,
                compact: true,
              );
            },
          ),
        ),
        if (stats.platformCounts.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            stats.platformCounts.entries
                .map((e) => '${_platformLabel(e.key)} ${e.value}')
                .join('  ·  '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ],
      ],
    );
  }

  String _platformLabel(String key) {
    return switch (key) {
      'facebook' => 'Facebook',
      'linkedin' => 'LinkedIn',
      'twitter' => 'X',
      _ => key,
    };
  }
}

class _StatDef {
  const _StatDef(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}