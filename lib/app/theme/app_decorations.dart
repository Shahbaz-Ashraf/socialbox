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
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark
            ? tokens.accentBorder
            : tokens.accentBorder.withValues(alpha: 0.65),
      ),
      boxShadow: isDark ? tokens.cardShadow : tokens.cardShadow,
    );
  }

  /// Elevated modern card with soft shadow — dashboards and forms.
  static BoxDecoration modernCard(BuildContext context, {Color? tint}) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>() ?? AppThemeTokens.light();
    final isDark = theme.brightness == Brightness.dark;
    final base = tint ?? theme.colorScheme.surface;

    return BoxDecoration(
      color: base,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withValues(
          alpha: isDark ? 0.35 : 0.5,
        ),
      ),
      boxShadow: tokens.cardShadow,
    );
  }

  static BoxDecoration accentHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? [
                theme.colorScheme.primary.withValues(alpha: 0.35),
                theme.colorScheme.surface.withValues(alpha: 0.2),
              ]
            : [
                theme.colorScheme.primary.withValues(alpha: 0.12),
                theme.colorScheme.surface,
              ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
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

  /// Settings / grouped list container.
  static BoxDecoration settingsGroup(BuildContext context) {
    return modernCard(context);
  }

  /// Subtle inset for nested list tiles inside a group card.
  static BoxDecoration settingsTileInset(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(12),
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