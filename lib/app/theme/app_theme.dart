import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      tertiary: AppColors.accentPink,
      brightness: Brightness.light,
      surface: AppColors.cardLight,
    );
    final tokens = AppThemeTokens.light();

    return _buildTheme(
      colorScheme: colorScheme,
      tokens: tokens,
      scaffoldColor: AppColors.scaffoldLight,
      cardColor: AppColors.cardLight,
      inputFill: const Color(0xFFF8FAFF),
      appBarBg: Colors.transparent,
      systemOverlay: SystemUiOverlayStyle.dark,
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark,
      secondary: AppColors.secondaryDark,
      tertiary: AppColors.accentViolet,
      brightness: Brightness.dark,
      surface: AppColors.cardDark,
    );
    final tokens = AppThemeTokens.dark();

    return _buildTheme(
      colorScheme: colorScheme,
      tokens: tokens,
      scaffoldColor: AppColors.scaffoldDark,
      cardColor: AppColors.cardDark,
      inputFill: const Color(0xFF22222E),
      appBarBg: Colors.transparent,
      systemOverlay: SystemUiOverlayStyle.light,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required AppThemeTokens tokens,
    required Color scaffoldColor,
    required Color cardColor,
    required Color inputFill,
    required Color appBarBg,
    required SystemUiOverlayStyle systemOverlay,
  }) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(14);

    final textTheme = TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: colorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: colorScheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        color: colorScheme.onSurface.withValues(alpha: 0.85),
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: colorScheme.onSurface.withValues(alpha: 0.55),
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldColor,
      textTheme: textTheme,
      extensions: [tokens],
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBg,
        foregroundColor: isDark ? Colors.white : colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: systemOverlay,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : colorScheme.onSurface,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: tokens.accentBorder),
        ),
        color: cardColor,
        shadowColor: colorScheme.primary.withValues(alpha: 0.2),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: tokens.navBarBackground,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.55),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.5),
          );
        }),
        elevation: 8,
        shadowColor: colorScheme.primary.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: radius),
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            Colors.white.withValues(alpha: 0.12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: radius),
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5)),
          foregroundColor: colorScheme.primary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
        selectedColor: colorScheme.primary.withValues(alpha: 0.22),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.25)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: tokens.accentBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: tokens.accentBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: tokens.accentBorder,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: radius),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radius),
        backgroundColor: isDark ? const Color(0xFF2A2A38) : colorScheme.inverseSurface,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primary.withValues(alpha: 0.15),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return isDark ? Colors.grey.shade400 : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurface.withValues(alpha: 0.2);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        thumbColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.2),
        overlayColor: colorScheme.primary.withValues(alpha: 0.12),
      ),
    );
  }
}