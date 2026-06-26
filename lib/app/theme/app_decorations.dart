import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppDecorations {
  AppDecorations._();

  /// Clean surface card — primary container style across the app.
  static BoxDecoration surfaceCard(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>() ?? AppThemeTokens.light();
    final isDark = theme.brightness == Brightness.dark;

    return BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark
            ? tokens.accentBorder
            : tokens.accentBorder.withValues(alpha: 0.9),
      ),
      boxShadow: tokens.cardShadow,
    );
  }

  static BoxDecoration elevatedCard(
    BuildContext context, {
    Color? accent,
    bool withGradient = false,
  }) {
    if (withGradient && accent != null) {
      return surfaceCard(context);
    }
    return surfaceCard(context);
  }

  static BoxDecoration iconBadge(Color color, {bool isDark = false}) {
    return BoxDecoration(
      color: color.withValues(alpha: isDark ? 0.2 : 0.12),
      borderRadius: BorderRadius.circular(12),
    );
  }

  /// Flat stat tile — no nested card border inside overview.
  static BoxDecoration statTile(BuildContext context, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: color.withValues(alpha: isDark ? 0.14 : 0.08),
      borderRadius: BorderRadius.circular(14),
    );
  }

  static BoxDecoration statCard(BuildContext context, Color color) {
    return statTile(context, color);
  }

  static BoxDecoration glassButton({double radius = 12}) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
    );
  }

  static BoxDecoration listItemSurface(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : AppColors.surfaceTintLight.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(14),
    );
  }

  static BoxDecoration heroOrb(Color color, {double opacity = 0.12}) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: opacity),
    );
  }
}