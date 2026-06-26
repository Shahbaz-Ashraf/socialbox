import 'package:equatable/equatable.dart';

import '../../../../core/utils/platform_utils.dart';
import 'app_theme_mode.dart';

class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.defaultPlatforms = const [],
    this.enableNotifications = true,
    this.enableApiPosting = false,
    this.reminderLeadMinutes = 15,
    this.autoRefreshTokens = true,
    this.fbAppId,
    this.fbAppSecret,
    this.liClientId,
    this.liClientSecret,
    this.twClientId,
    this.twClientSecret,
  });

  final AppThemeMode themeMode;
  final List<SocialPlatform> defaultPlatforms;
  final bool enableNotifications;
  final bool enableApiPosting;
  final int reminderLeadMinutes;
  final bool autoRefreshTokens;
  final String? fbAppId;
  final String? fbAppSecret;
  final String? liClientId;
  final String? liClientSecret;
  final String? twClientId;
  final String? twClientSecret;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    List<SocialPlatform>? defaultPlatforms,
    bool? enableNotifications,
    bool? enableApiPosting,
    int? reminderLeadMinutes,
    bool? autoRefreshTokens,
    String? fbAppId,
    String? fbAppSecret,
    String? liClientId,
    String? liClientSecret,
    String? twClientId,
    String? twClientSecret,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        defaultPlatforms: defaultPlatforms ?? this.defaultPlatforms,
        enableNotifications: enableNotifications ?? this.enableNotifications,
        enableApiPosting: enableApiPosting ?? this.enableApiPosting,
        reminderLeadMinutes:
            reminderLeadMinutes ?? this.reminderLeadMinutes,
        autoRefreshTokens: autoRefreshTokens ?? this.autoRefreshTokens,
        fbAppId: fbAppId ?? this.fbAppId,
        fbAppSecret: fbAppSecret ?? this.fbAppSecret,
        liClientId: liClientId ?? this.liClientId,
        liClientSecret: liClientSecret ?? this.liClientSecret,
        twClientId: twClientId ?? this.twClientId,
        twClientSecret: twClientSecret ?? this.twClientSecret,
      );

  @override
  List<Object?> get props => [
        themeMode,
        defaultPlatforms,
        enableNotifications,
        enableApiPosting,
        reminderLeadMinutes,
        autoRefreshTokens,
        fbAppId,
        fbAppSecret,
        liClientId,
        liClientSecret,
        twClientId,
        twClientSecret,
      ];
}
