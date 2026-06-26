import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/clipboard_service.dart';

import '../../domain/entities/comment_category.dart';
import '../../domain/repositories/comment_repository.dart';
import '../../domain/usecases/comment_usecases.dart';

abstract class CommentState extends Equatable {
  const CommentState();
  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {
  const CommentInitial();
}

class CommentLoading extends CommentState {
  const CommentLoading();
}

class CommentLoaded extends CommentState {
  const CommentLoaded({
    required this.comments,
    this.query = '',
    this.favoritesOnly = false,
    this.errorMessage,
  });

  final List<Comment> comments;
  final String query;
  final bool favoritesOnly;
  final String? errorMessage;

  List<Comment> get visibleComments {
    Iterable<Comment> list = comments;
    if (favoritesOnly) list = list.where((c) => c.isFavorite);
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((c) =>
          c.text.toLowerCase().contains(q) ||
          c.tags.any((t) => t.toLowerCase().contains(q)));
    }
    return list.toList();
  }

  @override
  List<Object?> get props => [comments, query, favoritesOnly, errorMessage];
}

class CommentError extends CommentState {
  const CommentError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class CommentCubit extends Cubit<CommentState> {
  CommentCubit({
    required this.createComment,
    required this.updateComment,
    required this.deleteComment,
    required this.toggleFavorite,
    required this.incrementUsageCount,
    required this.repository,
    required this.clipboard,
    required Stream<List<Comment>> Function(String) watchByCategory,
  })  : _watchByCategory = watchByCategory,
        super(const CommentInitial());

  final CreateComment createComment;
  final UpdateComment updateComment;
  final DeleteComment deleteComment;
  final ToggleFavorite toggleFavorite;
  final IncrementUsageCount incrementUsageCount;
  final CommentRepository repository;
  final ClipboardService clipboard;
  final Stream<List<Comment>> Function(String) _watchByCategory;

  StreamSubscription? _sub;
  String? _currentCategoryId;
  List<Comment> _currentComments = const [];

  void watchCategory(String categoryId) {
    if (_currentCategoryId == categoryId) return;
    _currentCategoryId = categoryId;
    _sub?.cancel();
    _subscribe();
  }

  void _subscribe() {
    if (_currentCategoryId == null) return;
    _sub = _watchByCategory(_currentCategoryId!).listen((comments) {
      _currentComments = comments;
      final s = state;
      emit(CommentLoaded(
        comments: comments,
        query: s is CommentLoaded ? s.query : '',
        favoritesOnly: s is CommentLoaded ? s.favoritesOnly : false,
      ));
    });
  }

  void setQuery(String query) {
    final s = state;
    if (s is CommentLoaded) {
      emit(CommentLoaded(
        comments: s.comments,
        query: query,
        favoritesOnly: s.favoritesOnly,
      ));
    } else {
      emit(CommentLoaded(comments: _currentComments, query: query));
    }
  }

  void toggleFavoritesFilter() {
    final s = state;
    if (s is CommentLoaded) {
      emit(CommentLoaded(
        comments: s.comments,
        query: s.query,
        favoritesOnly: !s.favoritesOnly,
      ));
    }
  }

  Future<bool> add({
    required String categoryId,
    required String text,
    List<String> tags = const [],
  }) async {
    final r = await createComment(CreateCommentParams(
      categoryId: categoryId,
      text: text,
      tags: tags,
    ));
    return r.isRight();
  }

  Future<bool> edit(Comment c) async {
    final r = await updateComment(c);
    return r.isRight();
  }

  Future<bool> remove(String id) async {
    final r = await deleteComment(id);
    return r.isRight();
  }

  Future<bool> toggleFav(String id) async {
    final r = await toggleFavorite(id);
    return r.isRight();
  }

  Future<void> copy(Comment c) async {
    await incrementUsageCount(c.id);
  }

  Future<void> copyWithClipboard(BuildContext context, Comment c) async {
    await clipboard.copyText(context, c.text);
    await copy(c);
  }

  Future<bool> restoreDeleted({
    required String categoryId,
    required String text,
    required List<String> tags,
  }) =>
      add(categoryId: categoryId, text: text, tags: tags);

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
