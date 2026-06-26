class AppConstants {
  AppConstants._();

  static const String packageId = 'com.linkedif.socialbox';
  static const String appName = 'SocialBox';
  static const String dbName = 'socialbox.db';
  static const int dbVersion = 2;

  // OAuth Redirect URIs
  static const String oauthScheme = 'com.linkedif.socialbox';
  static const String twitterRedirect = '$oauthScheme://oauth/twitter';
  static const String linkedinRedirect = '$oauthScheme://oauth/linkedin';
  static const String facebookRedirect = '$oauthScheme://oauth/facebook';

  // Notification
  static const String remindersChannelId = 'reminders_channel';
  static const String remindersChannelName = 'Post Reminders';
  static const String postingChannelId = 'posting_channel';
  static const String postingChannelName = 'Posting Results';
  static const String dailySummaryChannelId = 'daily_summary';
  static const String dailySummaryChannelName = 'Daily Summary';

  // WorkManager
  static const String scheduledPostingTask = 'socialbox_scheduled_posting';

  // Limits
  static const int maxCommentLength = 2000;
  static const int maxPostContentLength = 5000;
  static const int maxTagsPerItem = 10;

  // Default reminder lead time (minutes)
  static const int defaultReminderLeadMinutes = 15;

  // Storage keys
  static const String settingsKey = 'socialbox_settings';
  static const String oauthTokenPrefix = 'socialbox_oauth_';
  static const String promptTemplateKey = 'socialbox_prompt_template';
  static const String promptLastConfigKey = 'socialbox_prompt_last_config';
  static const String promptPresetsKey = 'socialbox_prompt_presets';
}
