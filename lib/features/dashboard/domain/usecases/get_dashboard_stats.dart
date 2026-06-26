import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../comment_templates/domain/repositories/comment_repository.dart';
import '../../../posting_log/domain/entities/posting_log.dart';
import '../../../posting_log/domain/repositories/log_repository.dart';
import '../../../posts/domain/repositories/post_repository.dart';
import '../../../reminders/domain/repositories/reminder_repository.dart';
import '../../../../core/utils/platform_utils.dart';
import '../entities/dashboard_stats.dart';

class GetDashboardStats extends UseCase<DashboardStats, NoParams> {
  GetDashboardStats({
    required this.postRepo,
    required this.commentRepo,
    required this.logRepo,
    required this.reminderRepo,
  });

  final PostRepository postRepo;
  final CommentRepository commentRepo;
  final LogRepository logRepo;
  final ReminderRepository reminderRepo;

  @override
  Future<Either<Failure, DashboardStats>> call(NoParams params) async {
    try {
      final postsResult = await postRepo.getAllPosts();
      final catsResult = await commentRepo.getAllCategories();
      final remindersResult = await reminderRepo.getAll();
      final logsResult = await logRepo.getAllLogs(const LogFilter());

      final posts = postsResult.getOrElse((_) => const []);
      final reminders = remindersResult.getOrElse((_) => const []);
      final logs = logsResult.getOrElse((_) => const []);
      final cats = catsResult.getOrElse((_) => const []);

      int totalComments = 0;
      int totalCopies = 0;
      for (final c in cats) {
        final list = await commentRepo.getCommentsByCategory(c.id);
        list.fold((_) {}, (list) {
          totalComments += list.length;
          totalCopies += list.fold<int>(0, (sum, c) => sum + c.usageCount);
        });
      }

      final now = DateTime.now();
      final upcomingPosts = posts
          .where((p) =>
              p.scheduledAt != null &&
              p.scheduledAt!.isAfter(now) &&
              p.status == PostStatus.scheduled)
          .toList()
        ..sort((a, b) => a.scheduledAt!.compareTo(b.scheduledAt!));

      final upcomingReminders = reminders
          .where((r) => r.isEnabled && r.scheduledAt.isAfter(now))
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      final platformCounts = <String, int>{};
      for (final p in posts) {
        for (final plat in p.platforms) {
          platformCounts[plat.name] = (platformCounts[plat.name] ?? 0) + 1;
        }
      }

      return Right(DashboardStats(
        totalPosts: posts.length,
        draftPosts:
            posts.where((p) => p.status == PostStatus.draft).length,
        scheduledPosts:
            posts.where((p) => p.status == PostStatus.scheduled).length,
        postedPosts: posts
            .where((p) =>
                p.status == PostStatus.posted ||
                p.status == PostStatus.partial)
            .length,
        failedPosts:
            posts.where((p) => p.status == PostStatus.failed).length,
        totalCommentCategories: cats.length,
        totalComments: totalComments,
        totalCopies: totalCopies,
        totalLogs: logs.length,
        upcomingPosts: upcomingPosts.take(5).toList(),
        upcomingReminders: upcomingReminders.take(5).toList(),
        recentActivity: logs.take(8).toList(),
        platformCounts: platformCounts,
      ));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
