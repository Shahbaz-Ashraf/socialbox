import '../../../../core/database/app_database.dart';

class ReminderLocalDataSource {
  ReminderLocalDataSource(this._db);
  final AppDatabase _db;

  ReminderDao get _dao => _db.reminderDao;

  Future<List<ReminderRow>> getAll() => _dao.getAllReminders();
  Future<ReminderRow?> getById(String id) => _dao.getReminderById(id);
  Stream<List<ReminderRow>> watchAll() => _dao.watchAllReminders();
  Stream<List<ReminderRow>> watchForPost(String postId) =>
      _dao.watchRemindersForPost(postId);
  Future<void> insert(RemindersTableCompanion entry) => _dao.insertReminder(entry);
  Future<bool> update(RemindersTableCompanion entry) =>
      _dao.updateReminder(entry);
  Future<int> delete(String id) => _dao.deleteReminder(id);
  Future<void> toggle(String id) => _dao.toggleEnabled(id);
  Future<int> deleteForPost(String postId) => _dao.deleteRemindersForPost(postId);
}
