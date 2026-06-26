import '../../../../core/database/app_database.dart';

class LogLocalDataSource {
  LogLocalDataSource(this._db);
  final AppDatabase _db;

  LogDao get _dao => _db.logDao;

  Future<List<PostingLogRow>> getAll() => _dao.getAllLogs();
  Future<List<PostingLogRow>> getForPost(String postId) =>
      _dao.getLogsForPost(postId);
  Stream<List<PostingLogRow>> watchAll() => _dao.watchAllLogs();
  Stream<List<PostingLogRow>> watchForPost(String postId) =>
      _dao.watchLogsForPost(postId);
  Future<void> insert(PostingLogsTableCompanion entry) => _dao.insertLog(entry);
  Future<int> delete(String id) => _dao.deleteLog(id);
  Future<int> deleteForPost(String postId) => _dao.deleteLogsForPost(postId);
}
