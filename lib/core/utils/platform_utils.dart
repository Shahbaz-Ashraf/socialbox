import 'package:flutter/material.dart';

enum SocialPlatform { facebook, linkedin, twitter }

extension SocialPlatformX on SocialPlatform {
  String get displayName => switch (this) {
        SocialPlatform.facebook => 'Facebook',
        SocialPlatform.linkedin => 'LinkedIn',
        SocialPlatform.twitter => 'Twitter / X',
      };

  String get shortName => switch (this) {
        SocialPlatform.facebook => 'FB',
        SocialPlatform.linkedin => 'LI',
        SocialPlatform.twitter => 'X',
      };

  IconData get icon => switch (this) {
        SocialPlatform.facebook => Icons.facebook_rounded,
        SocialPlatform.linkedin => Icons.business_center_rounded,
        SocialPlatform.twitter => Icons.alternate_email_rounded,
      };

  Color get color => switch (this) {
        SocialPlatform.facebook => const Color(0xFF1877F2),
        SocialPlatform.linkedin => const Color(0xFF0A66C2),
        SocialPlatform.twitter => const Color(0xFF000000),
      };

  String get webUrl => switch (this) {
        SocialPlatform.facebook => 'https://facebook.com',
        SocialPlatform.linkedin => 'https://linkedin.com/feed',
        SocialPlatform.twitter => 'https://x.com/home',
      };

  String get name => switch (this) {
        SocialPlatform.facebook => 'facebook',
        SocialPlatform.linkedin => 'linkedin',
        SocialPlatform.twitter => 'twitter',
      };

  static SocialPlatform? fromName(String? name) {
    if (name == null) return null;
    return SocialPlatform.values.firstWhere(
      (p) => p.name == name,
      orElse: () => SocialPlatform.twitter,
    );
  }
}

enum PostStatus { draft, scheduled, partial, posted, failed }

extension PostStatusX on PostStatus {
  String get label => switch (this) {
        PostStatus.draft => 'Draft',
        PostStatus.scheduled => 'Scheduled',
        PostStatus.partial => 'Partial',
        PostStatus.posted => 'Posted',
        PostStatus.failed => 'Failed',
      };

  Color get color => switch (this) {
        PostStatus.draft => const Color(0xFF607D8B),
        PostStatus.scheduled => const Color(0xFF2196F3),
        PostStatus.partial => const Color(0xFFFF9800),
        PostStatus.posted => const Color(0xFF4CAF50),
        PostStatus.failed => const Color(0xFFF44336),
      };

  IconData get icon => switch (this) {
        PostStatus.draft => Icons.edit_note_rounded,
        PostStatus.scheduled => Icons.schedule_rounded,
        PostStatus.partial => Icons.timelapse_rounded,
        PostStatus.posted => Icons.check_circle_rounded,
        PostStatus.failed => Icons.error_rounded,
      };

  static PostStatus fromName(String? name) {
    if (name == null) return PostStatus.draft;
    return PostStatus.values.firstWhere(
      (s) => s.name == name,
      orElse: () => PostStatus.draft,
    );
  }
}

enum RecurringType { none, daily, weekly, custom }

extension RecurringTypeX on RecurringType {
  String get label => switch (this) {
        RecurringType.none => 'None',
        RecurringType.daily => 'Daily',
        RecurringType.weekly => 'Weekly',
        RecurringType.custom => 'Custom',
      };
}

enum LogStatus { pending, posted, failed, skipped }

extension LogStatusX on LogStatus {
  String get label => switch (this) {
        LogStatus.pending => 'Pending',
        LogStatus.posted => 'Posted',
        LogStatus.failed => 'Failed',
        LogStatus.skipped => 'Skipped',
      };

  Color get color => switch (this) {
        LogStatus.pending => const Color(0xFFFF9800),
        LogStatus.posted => const Color(0xFF4CAF50),
        LogStatus.failed => const Color(0xFFF44336),
        LogStatus.skipped => const Color(0xFF9E9E9E),
      };

  IconData get icon => switch (this) {
        LogStatus.pending => Icons.hourglass_top_rounded,
        LogStatus.posted => Icons.check_circle_rounded,
        LogStatus.failed => Icons.cancel_rounded,
        LogStatus.skipped => Icons.skip_next_rounded,
      };

  static LogStatus fromName(String? name) {
    if (name == null) return LogStatus.pending;
    return LogStatus.values.firstWhere(
      (s) => s.name == name,
      orElse: () => LogStatus.pending,
    );
  }
}

enum PostingMethod { manual, api }

extension PostingMethodX on PostingMethod {
  String get label => switch (this) {
        PostingMethod.manual => 'Manual',
        PostingMethod.api => 'API',
      };

  IconData get icon => switch (this) {
        PostingMethod.manual => Icons.touch_app_rounded,
        PostingMethod.api => Icons.cloud_done_rounded,
      };

  static PostingMethod fromName(String? name) {
    if (name == null) return PostingMethod.manual;
    return PostingMethod.values.firstWhere(
      (m) => m.name == name,
      orElse: () => PostingMethod.manual,
    );
  }
}

enum ReminderRepeat { none, daily, weekly, custom }

extension ReminderRepeatX on ReminderRepeat {
  String get label => switch (this) {
        ReminderRepeat.none => 'Once',
        ReminderRepeat.daily => 'Daily',
        ReminderRepeat.weekly => 'Weekly',
        ReminderRepeat.custom => 'Custom',
      };

  IconData get icon => switch (this) {
        ReminderRepeat.none => Icons.event_rounded,
        ReminderRepeat.daily => Icons.today_rounded,
        ReminderRepeat.weekly => Icons.date_range_rounded,
        ReminderRepeat.custom => Icons.tune_rounded,
      };

  Color get color => switch (this) {
        ReminderRepeat.none => const Color(0xFF607D8B),
        ReminderRepeat.daily => const Color(0xFF2196F3),
        ReminderRepeat.weekly => const Color(0xFF9C27B0),
        ReminderRepeat.custom => const Color(0xFFFF9800),
      };

  static ReminderRepeat fromName(String? name) {
    if (name == null) return ReminderRepeat.none;
    return ReminderRepeat.values.firstWhere(
      (r) => r.name == name,
      orElse: () => ReminderRepeat.none,
    );
  }
}
