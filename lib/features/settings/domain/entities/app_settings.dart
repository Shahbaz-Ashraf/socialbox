import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/platform_utils.dart';

class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.defaultPlatforms = const [],
    this.enableNotifications = true,
    this.enableApiPosting = false,
    this.reminderLeadMinutes = 15,
    this.autoRefreshTokens = true,
  });

  final ThemeMode themeMode;
  final List<SocialPlatform> defaultPlatforms;
  final bool enableNotifications;
  final bool enableApiPosting;
  final int reminderLeadMinutes;
  final bool autoRefreshTokens;

  AppSettings copyWith({
    ThemeMode? themeMode,
    List<SocialPlatform>? defaultPlatforms,
    bool? enableNotifications,
    bool? enableApiPosting,
    int? reminderLeadMinutes,
    bool? autoRefreshTokens,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        defaultPlatforms: defaultPlatforms ?? this.defaultPlatforms,
        enableNotifications: enableNotifications ?? this.enableNotifications,
        enableApiPosting: enableApiPosting ?? this.enableApiPosting,
        reminderLeadMinutes:
            reminderLeadMinutes ?? this.reminderLeadMinutes,
        autoRefreshTokens: autoRefreshTokens ?? this.autoRefreshTokens,
      );

  @override
  List<Object?> get props => [
        themeMode,
        defaultPlatforms,
        enableNotifications,
        enableApiPosting,
        reminderLeadMinutes,
        autoRefreshTokens,
      ];
}
