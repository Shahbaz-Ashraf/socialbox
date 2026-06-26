import 'package:workmanager/workmanager.dart';

import '../../features/posts/data/datasources/post_local_datasource.dart';
import '../../features/posts/data/models/social_post_model.dart';
import '../../features/posts/domain/usecases/publish_via_api.dart';
import '../constants/app_constants.dart';
import '../database/app_database.dart';
import '../utils/platform_utils.dart';
import '../../injection_container.dart';
import 'notification_service.dart';

class BackgroundService {
  static Future<void> register() async {
    await Workmanager().registerPeriodicTask(
      AppConstants.scheduledPostingTask,
      AppConstants.scheduledPostingTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  }

  static Future<bool> executeScheduledPosting() async {
    try {
      await configureDependencies();
      final notifService = getIt<NotificationService>();
      await notifService.init();

      final postLocal = getIt<PostLocalDataSource>();
      final logDao = getIt<AppDatabase>().logDao;
      final publishViaApi = getIt<PublishViaApi>();

      final dueRows =
          await postLocal.getPostsDueForPosting(DateTime.now());

      for (final row in dueRows) {
        final platformNames = await postLocal.getPlatformsForPost(row.id);
        final platforms = platformNames
            .map((n) => SocialPlatformX.fromName(n))
            .whereType<SocialPlatform>()
            .toList();
        final post = row.toDomain(platforms);

        for (final platform in post.platforms) {
          final alreadyPosted =
              await logDao.isPostedToday(post.id, platform.name);
          if (alreadyPosted) continue;

          await publishViaApi(
            PublishViaApiParams(postId: post.id, platform: platform),
          );
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}