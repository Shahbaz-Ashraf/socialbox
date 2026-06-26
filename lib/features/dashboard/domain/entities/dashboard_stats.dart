import 'package:equatable/equatable.dart';

import '../../../posting_log/domain/entities/posting_log.dart';
import '../../../posts/domain/entities/social_post.dart';
import '../../../reminders/domain/entities/reminder.dart';

class DashboardStats extends Equatable {
  const DashboardStats({
    required this.totalPosts,
    required this.draftPosts,
    required this.scheduledPosts,
    required this.postedPosts,
    required this.failedPosts,
    required this.totalCommentCategories,
    required this.totalComments,
    required this.totalCopies,
    required this.totalLogs,
    required this.upcomingPosts,
    required this.upcomingReminders,
    required this.recentActivity,
    required this.platformCounts,
  });

  final int totalPosts;
  final int draftPosts;
  final int scheduledPosts;
  final int postedPosts;
  final int failedPosts;
  final int totalCommentCategories;
  final int totalComments;
  final int totalCopies;
  final int totalLogs;
  final List<SocialPost> upcomingPosts;
  final List<Reminder> upcomingReminders;
  final List<PostingLog> recentActivity;
  final Map<String, int> platformCounts;

  @override
  List<Object?> get props => [
        totalPosts,
        draftPosts,
        scheduledPosts,
        postedPosts,
        failedPosts,
        totalCommentCategories,
        totalComments,
        totalCopies,
        totalLogs,
        upcomingPosts,
        upcomingReminders,
        recentActivity,
        platformCounts,
      ];
}
