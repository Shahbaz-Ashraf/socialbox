import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primaryLight = Color(0xFF4F46E5);
  static const Color secondaryLight = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF818CF8);
  static const Color secondaryDark = Color(0xFF2DD4BF);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentViolet = Color(0xFF8B5CF6);

  static const List<Color> brandGradient = [
    Color(0xFF4F46E5),
    Color(0xFF7C3AED),
    Color(0xFF14B8A6),
  ];

  static const List<Color> brandGradientDark = [
    Color(0xFF6366F1),
    Color(0xFFA78BFA),
    Color(0xFF2DD4BF),
  ];

  // Surfaces — light
  static const Color scaffoldLight = Color(0xFFF5F6FA);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color surfaceTintLight = Color(0xFFEEF0F5);

  // Surfaces — dark
  static const Color scaffoldDark = Color(0xFF0C0C12);
  static const Color cardDark = Color(0xFF1A1A24);
  static const Color surfaceTintDark = Color(0xFF1E1E2E);

  // Stat palette
  static const Color statPosts = Color(0xFF6366F1);
  static const Color statScheduled = Color(0xFF3B82F6);
  static const Color statComments = Color(0xFFF97316);
  static const Color statCopies = Color(0xFFEC4899);
  static const Color statPosted = Color(0xFF22C55E);
  static const Color statDrafts = Color(0xFF64748B);
  static const Color statCategories = Color(0xFFA855F7);
  static const Color statLogs = Color(0xFF06B6D4);

  static Color surface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? surfaceTintDark : surfaceTintLight;
  }

  static List<Color> gradientFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? brandGradientDark
        : brandGradient;
  }

  static LinearGradient brandLinearGradient(BuildContext context) {
    final colors = gradientFor(context);
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient subtleCardGradient(BuildContext context, Color accent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: [
        accent.withValues(alpha: isDark ? 0.22 : 0.14),
        accent.withValues(alpha: isDark ? 0.08 : 0.04),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

/// Custom theme tokens beyond Material ColorScheme.
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.brandGradient,
    required this.cardShadow,
    required this.heroGradient,
    required this.navBarBackground,
    required this.accentBorder,
  });

  final List<Color> brandGradient;
  final List<BoxShadow> cardShadow;
  final LinearGradient heroGradient;
  final Color navBarBackground;
  final Color accentBorder;

  static AppThemeTokens light() {
    return AppThemeTokens(
      brandGradient: AppColors.brandGradient,
      cardShadow: const [
        BoxShadow(
          color: Color(0x0A0F172A),
          blurRadius: 20,
          offset: Offset(0, 4),
        ),
        BoxShadow(
          color: Color(0x050F172A),
          blurRadius: 6,
          offset: Offset(0, 1),
        ),
      ],
      heroGradient: const LinearGradient(
        colors: [Color(0xFF4F46E5), Color(0xFF6366F1), Color(0xFF7C3AED)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.45, 1.0],
      ),
      navBarBackground: Colors.white,
      accentBorder: const Color(0xFFE8ECF4),
    );
  }

  static AppThemeTokens dark() {
    return AppThemeTokens(
      brandGradient: AppColors.brandGradientDark,
      cardShadow: const [
        BoxShadow(
          color: Color(0x40000000),
          blurRadius: 20,
          offset: Offset(0, 6),
        ),
      ],
      heroGradient: const LinearGradient(
        colors: [Color(0xFF312E81), Color(0xFF4C1D95)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      navBarBackground: const Color(0xFF16161E),
      accentBorder: const Color(0xFF2D2D3D),
    );
  }

  @override
  AppThemeTokens copyWith({
    List<Color>? brandGradient,
    List<BoxShadow>? cardShadow,
    LinearGradient? heroGradient,
    Color? navBarBackground,
    Color? accentBorder,
  }) {
    return AppThemeTokens(
      brandGradient: brandGradient ?? this.brandGradient,
      cardShadow: cardShadow ?? this.cardShadow,
      heroGradient: heroGradient ?? this.heroGradient,
      navBarBackground: navBarBackground ?? this.navBarBackground,
      accentBorder: accentBorder ?? this.accentBorder,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) return this;
    return this;
  }
}