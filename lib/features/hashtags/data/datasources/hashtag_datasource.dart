import '../../../../core/database/app_database.dart';

class HashtagLocalDataSource {
  HashtagLocalDataSource(this._db);
  final AppDatabase _db;

  HashtagDao get _dao => _db.hashtagDao;

  Stream<List<HashtagSuggestionRow>> watchTop({int limit = 30}) =>
      _dao.watchTopSuggestions(limit: limit);

  Future<List<HashtagSuggestionRow>> getTop({int limit = 30}) =>
      _dao.getTopSuggestions(limit: limit);

  Future<void> recordUsage(List<String> tags) => _dao.recordUsage(tags);

  Future<void> clear() => _dao.clearAll();
}
