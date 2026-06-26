import 'package:flutter/material.dart';

import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_text_styles.dart';

class DashboardListItem extends StatelessWidget {
  const DashboardListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    this.onTap,
    this.showChevron = true,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = iconColor ?? theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: AppDecorations.listItemSurface(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: AppDecorations.iconBadge(accent),
                    child: Icon(icon, size: 18, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.subtitle.copyWith(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AppTextStyles.caption.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showChevron && onTap != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: theme.hintColor,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}