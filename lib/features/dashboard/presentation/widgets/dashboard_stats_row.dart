import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/dashboard_stats.dart';
import 'stat_card.dart';

class DashboardStatsRow extends StatefulWidget {
  const DashboardStatsRow({super.key, required this.stats});

  final DashboardStats stats;

  @override
  State<DashboardStatsRow> createState() => _DashboardStatsRowState();
}

class _DashboardStatsRowState extends State<DashboardStatsRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final cols = width > 600 ? 4 : 2;

    final primaryStats = [
      _StatDef('Posts', '${widget.stats.totalPosts}', Icons.article_outlined,
          AppColors.statPosts),
      _StatDef('Scheduled', '${widget.stats.scheduledPosts}',
          Icons.schedule_outlined, AppColors.statScheduled),
      _StatDef('Comments', '${widget.stats.totalComments}',
          Icons.chat_bubble_outline_rounded, AppColors.statComments),
      _StatDef('Copies', '${widget.stats.totalCopies}',
          Icons.content_copy_rounded, AppColors.statCopies),
    ];

    final secondaryStats = [
      _StatDef('Posted', '${widget.stats.postedPosts}',
          Icons.check_circle_outline_rounded, AppColors.statPosted),
      _StatDef('Drafts', '${widget.stats.draftPosts}',
          Icons.edit_note_outlined, AppColors.statDrafts),
      _StatDef('Categories', '${widget.stats.totalCommentCategories}',
          Icons.folder_outlined, AppColors.statCategories),
      _StatDef('Logs', '${widget.stats.totalLogs}', Icons.history_rounded,
          AppColors.statLogs),
    ];

    final visibleStats =
        _expanded ? [...primaryStats, ...secondaryStats] : primaryStats;

    return Container(
      decoration: AppDecorations.surfaceCard(context),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Overview',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _expanded ? 'Show less' : 'Show all',
                        style: AppTextStyles.caption.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        _expanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: width > 600 ? 2.4 : 2.1,
              children: visibleStats
                  .map(
                    (s) => StatCard(
                      label: s.label,
                      value: s.value,
                      icon: s.icon,
                      color: s.color,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDef {
  const _StatDef(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}