import 'package:flutter/material.dart';

import '../../domain/entities/app_theme_mode.dart';

extension AppThemeModePresentation on AppThemeMode {
  ThemeMode toThemeMode() => switch (this) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };
}

AppThemeMode appThemeModeFromThemeMode(ThemeMode mode) => switch (mode) {
      ThemeMode.system => AppThemeMode.system,
      ThemeMode.light => AppThemeMode.light,
      ThemeMode.dark => AppThemeMode.dark,
    };