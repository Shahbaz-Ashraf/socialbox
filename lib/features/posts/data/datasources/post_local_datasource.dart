import '../../../../core/database/app_database.dart';

class PostLocalDataSource {
  PostLocalDataSource(this._db);
  final AppDatabase _db;

  PostDao get _dao => _db.postDao;

  Future<List<SocialPostRow>> getAllPosts() => _dao.getAllPosts();
  Future<SocialPostRow?> getPostById(String id) => _dao.getPostById(id);
  Future<List<SocialPostRow>> getPostsDueForPosting(DateTime now) =>
      _dao.getPostsDueForPosting(now);

  Future<void> insertPost(
    SocialPostsTableCompanion entry,
    List<String> platforms,
  ) =>
      _dao.insertPost(entry, platforms);

  Future<bool> updatePost(
    SocialPostsTableCompanion entry,
    List<String> platforms,
  ) =>
      _dao.updatePost(entry, platforms);

  Future<int> deletePost(String id) => _dao.deletePost(id);

  Future<void> updateStatus(String id, String status) =>
      _dao.updatePostStatus(id, status);

  Future<List<String>> getPlatformsForPost(String id) =>
      _dao.getPlatformsForPost(id);

  Stream<List<SocialPostRow>> watchAll() => _dao.watchAllPosts();
  Stream<List<SocialPostRow>> watchByStatus(String status) =>
      _dao.watchPostsByStatus(status);
  Stream<SocialPostRow?> watchPostById(String id) => _dao.watchPostById(id);
  Stream<List<String>> watchPlatforms(String id) =>
      _dao.watchPlatformsForPost(id);
}
