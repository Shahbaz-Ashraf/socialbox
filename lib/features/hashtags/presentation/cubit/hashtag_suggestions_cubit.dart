import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/hashtag_suggestion.dart';
import '../../domain/repositories/hashtag_repository.dart';
import '../../domain/usecases/hashtag_usecases.dart';

class HashtagSuggestionsState extends Equatable {
  const HashtagSuggestionsState({
    this.suggestions = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  final List<HashtagSuggestion> suggestions;
  final bool isLoading;
  final String? errorMessage;

  HashtagSuggestionsState copyWith({
    List<HashtagSuggestion>? suggestions,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) =>
      HashtagSuggestionsState(
        suggestions: suggestions ?? this.suggestions,
        isLoading: isLoading ?? this.isLoading,
        errorMessage:
            clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [suggestions, isLoading, errorMessage];
}

class HashtagSuggestionsCubit extends Cubit<HashtagSuggestionsState> {
  HashtagSuggestionsCubit({
    required WatchTopHashtagSuggestions watchTopHashtagSuggestions,
    HashtagFilter filter = const HashtagFilter(limit: 12),
  })  : _watch = watchTopHashtagSuggestions,
        _filter = filter,
        super(const HashtagSuggestionsState()) {
    _subscribe();
  }

  final WatchTopHashtagSuggestions _watch;
  final HashtagFilter _filter;
  StreamSubscription? _sub;

  void _subscribe() {
    _sub?.cancel();
    _sub = _watch(_filter).listen((either) {
      either.fold(
        (f) => emit(
          state.copyWith(isLoading: false, errorMessage: f.message),
        ),
        (list) => emit(
          HashtagSuggestionsState(suggestions: list, isLoading: false),
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}