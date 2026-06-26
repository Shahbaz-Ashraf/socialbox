import '../../../../core/database/app_database.dart';

class CommentLocalDataSource {
  CommentLocalDataSource(this._db);
  final AppDatabase _db;

  CommentDao get _dao => _db.commentDao;

  // Categories
  Stream<List<CommentCategoryRow>> watchCategories() =>
      _dao.watchAllCategories();

  Future<List<CommentCategoryRow>> getAllCategories() =>
      _dao.getAllCategories();

  Future<CommentCategoryRow?> getCategoryById(String id) =>
      _dao.getCategoryById(id);

  Future<void> insertCategory(CommentCategoriesTableCompanion entry) =>
      _dao.insertCategory(entry);

  Future<bool> updateCategory(CommentCategoriesTableCompanion entry) =>
      _dao.updateCategory(entry);

  Future<int> deleteCategory(String id) => _dao.deleteCategory(id);

  // Comments
  Stream<List<CommentRow>> watchByCategory(String categoryId) =>
      _dao.watchByCategory(categoryId);

  Stream<List<CommentRow>> watchAllComments() => _dao.watchAllComments();

  Future<List<CommentRow>> getByCategory(String categoryId) =>
      _dao.getByCategory(categoryId);

  Future<List<CommentRow>> searchComments(String query) =>
      _dao.searchComments(query);

  Future<CommentRow?> getCommentById(String id) => _dao.getCommentById(id);

  Future<void> insertComment(CommentsTableCompanion entry) =>
      _dao.insertComment(entry);

  Future<bool> updateComment(CommentsTableCompanion entry) =>
      _dao.updateComment(entry);

  Future<int> deleteComment(String id) => _dao.deleteComment(id);

  Future<void> toggleFavorite(String id) => _dao.toggleFavorite(id);

  Future<void> incrementUsageCount(String id) => _dao.incrementUsageCount(id);

  Future<int> deleteCommentsByCategory(String categoryId) =>
      _dao.deleteCommentsByCategory(categoryId);
}
