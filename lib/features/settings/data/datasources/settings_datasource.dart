import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/app_theme_mode.dart';

class SettingsDataSource {
  SettingsDataSource(this._prefs);
  final SharedPreferences _prefs;

  AppSettings load() {
    final raw = _prefs.getString(AppConstants.settingsKey);
    if (raw == null) return const AppSettings();
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AppSettings(
        themeMode: AppThemeModeX.fromName(map['themeMode'] as String?),
        defaultPlatforms:
            ((map['defaultPlatforms'] as List?) ?? const [])
                .map((n) => SocialPlatformX.fromName(n as String))
                .whereType<SocialPlatform>()
                .toList(),
        enableNotifications: map['enableNotifications'] as bool? ?? true,
        enableApiPosting: map['enableApiPosting'] as bool? ?? false,
        reminderLeadMinutes: map['reminderLeadMinutes'] as int? ?? 15,
        autoRefreshTokens: map['autoRefreshTokens'] as bool? ?? true,
        fbAppId: map['fbAppId'] as String?,
        fbAppSecret: map['fbAppSecret'] as String?,
        liClientId: map['liClientId'] as String?,
        liClientSecret: map['liClientSecret'] as String?,
        twClientId: map['twClientId'] as String?,
        twClientSecret: map['twClientSecret'] as String?,
      );
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> save(AppSettings settings) async {
    await _prefs.setString(
      AppConstants.settingsKey,
      jsonEncode({
        'themeMode': settings.themeMode.name,
        'defaultPlatforms':
            settings.defaultPlatforms.map((p) => p.name).toList(),
        'enableNotifications': settings.enableNotifications,
        'enableApiPosting': settings.enableApiPosting,
        'reminderLeadMinutes': settings.reminderLeadMinutes,
        'autoRefreshTokens': settings.autoRefreshTokens,
        if (settings.fbAppId != null) 'fbAppId': settings.fbAppId,
        if (settings.fbAppSecret != null) 'fbAppSecret': settings.fbAppSecret,
        if (settings.liClientId != null) 'liClientId': settings.liClientId,
        if (settings.liClientSecret != null)
          'liClientSecret': settings.liClientSecret,
        if (settings.twClientId != null) 'twClientId': settings.twClientId,
        if (settings.twClientSecret != null)
          'twClientSecret': settings.twClientSecret,
      }),
    );
  }
}
