import 'package:flutter/material.dart';

import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_text_styles.dart';

class DashboardSection extends StatelessWidget {
  const DashboardSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
    this.accentColor,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = accentColor ?? theme.colorScheme.primary;

    return Container(
      decoration: AppDecorations.surfaceCard(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: AppDecorations.iconBadge(accent),
                  child: Icon(icon, size: 17, color: accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 4),
            Divider(
              height: 20,
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class DashboardEmptyState extends StatelessWidget {
  const DashboardEmptyState({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: AppDecorations.listItemSurface(context),
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 32,
            color: theme.hintColor.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: theme.hintColor,
              fontSize: 13,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}