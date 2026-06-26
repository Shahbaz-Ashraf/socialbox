import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/comment_category.dart';
import '../../domain/repositories/comment_repository.dart';
import '../../domain/usecases/category_usecases.dart';
import '../../domain/usecases/get_all_categories.dart';

// ============================================================================
// States
// ============================================================================

abstract class CategoryState extends Equatable {
  const CategoryState();
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryLoaded extends CategoryState {
  const CategoryLoaded({
    required this.categories,
    this.commentCounts = const {},
  });

  final List<CommentCategory> categories;
  final Map<String, int> commentCounts;

  CategoryLoaded copyWith({
    List<CommentCategory>? categories,
    Map<String, int>? commentCounts,
  }) =>
      CategoryLoaded(
        categories: categories ?? this.categories,
        commentCounts: commentCounts ?? this.commentCounts,
      );

  @override
  List<Object?> get props => [categories, commentCounts];
}

class CategoryError extends CategoryState {
  const CategoryError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ============================================================================
// Cubit
// ============================================================================

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit({
    required this.repository,
    required this.getAllCategories,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
  }) : super(const CategoryInitial()) {
    _subscribe();
  }

  final CommentRepository repository;
  final GetAllCategories getAllCategories;
  final CreateCategory createCategory;
  final UpdateCategory updateCategory;
  final DeleteCategory deleteCategory;

  StreamSubscription? _categoriesSub;
  final Map<String, StreamSubscription> _countSubs = {};

  void _subscribe() {
    _categoriesSub?.cancel();
    _categoriesSub = repository.watchCategories().listen((cats) {
      final loaded = state is CategoryLoaded
          ? (state as CategoryLoaded)
          : CategoryLoaded(categories: cats);
      emit(loaded.copyWith(categories: cats));

      // (Re)subscribe to per-category count streams
      final keep = <String>{};
      for (final c in cats) {
        keep.add(c.id);
        if (_countSubs.containsKey(c.id)) continue;
        _countSubs[c.id] = repository
            .watchCommentsByCategory(c.id)
            .listen((_) => _refreshCount(c.id));
      }
      // Clean up removed subscriptions
      _countSubs.removeWhere((id, sub) {
        if (keep.contains(id)) return false;
        sub.cancel();
        return true;
      });
    });
  }

  Future<void> _refreshCount(String categoryId) async {
    final r = await repository.getCommentsByCategory(categoryId);
    final cur = state;
    if (cur is CategoryLoaded && r.isRight()) {
      final list = r.getOrElse((_) => const <Comment>[]);
      final newCounts = Map<String, int>.from(cur.commentCounts);
      newCounts[categoryId] = list.length;
      emit(cur.copyWith(commentCounts: newCounts));
    }
  }

  Future<void> load() async {
    emit(const CategoryLoading());
    final result = await getAllCategories(const NoParams());
    result.fold(
      (failure) => emit(CategoryError(_message(failure))),
      (_) {/* stream will emit loaded */},
    );
  }

  Future<bool> add({
    required String name,
    required String icon,
    required String colorHex,
  }) async {
    final result = await createCategory(CreateCategoryParams(
      name: name,
      icon: icon,
      colorHex: colorHex,
    ));
    return result.isRight();
  }

  Future<bool> edit(CommentCategory category) async {
    final result = await updateCategory(category);
    return result.isRight();
  }

  Future<Either<Failure, Unit>> remove(String id) => deleteCategory(id);

  /// Reorders user-defined categories and persists new [sortOrder] values.
  /// Predefined categories are ignored.
  Future<void> reorderCustom(int oldIndex, int newIndex) async {
    final cur = state;
    if (cur is! CategoryLoaded) return;

    final custom = cur.categories.where((c) => !c.isPredefined).toList();
    if (oldIndex < 0 ||
        oldIndex >= custom.length ||
        newIndex < 0 ||
        newIndex >= custom.length) {
      return;
    }

    if (newIndex > oldIndex) newIndex -= 1;
    final item = custom.removeAt(oldIndex);
    custom.insert(newIndex, item);

    final predefinedCount =
        cur.categories.where((c) => c.isPredefined).length;
    final updates = <Future<bool>>[];
    for (var i = 0; i < custom.length; i++) {
      final c = custom[i];
      final newOrder = predefinedCount + i;
      if (c.sortOrder == newOrder) continue;
      updates.add(edit(c.copyWith(sortOrder: newOrder)));
    }

    // Optimistic UI while persisting
    final predefined =
        cur.categories.where((c) => c.isPredefined).toList();
    emit(cur.copyWith(categories: [...predefined, ...custom]));

    for (final u in updates) {
      await u;
    }
  }

  String _message(Failure f) => f.message;

  @override
  Future<void> close() {
    _categoriesSub?.cancel();
    for (final s in _countSubs.values) {
      s.cancel();
    }
    _countSubs.clear();
    return super.close();
  }
}
