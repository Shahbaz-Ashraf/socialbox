import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/settings/domain/entities/app_settings.dart';
import '../../features/settings/domain/entities/app_theme_mode.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key, this.iconColor});

  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, AppSettings>(
      builder: (context, settings) {
        final (icon, label, next) = switch (settings.themeMode) {
          AppThemeMode.light => (
              Icons.dark_mode_rounded,
              'Switch to dark',
              AppThemeMode.dark,
            ),
          AppThemeMode.dark => (
              Icons.brightness_auto_rounded,
              'Switch to system',
              AppThemeMode.system,
            ),
          AppThemeMode.system => (
              Icons.light_mode_rounded,
              'Switch to light',
              AppThemeMode.light,
            ),
        };

        return IconButton(
          tooltip: label,
          icon: Icon(icon, color: iconColor),
          onPressed: () {
            context.read<SettingsCubit>().update(
                  settings.copyWith(themeMode: next),
                );
          },
        );
      },
    );
  }
}