import 'package:flutter/material.dart';

import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_text_styles.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: AppDecorations.statTile(context, color),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: AppDecorations.iconBadge(color),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppTextStyles.headline.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    height: 1.1,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: theme.hintColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}