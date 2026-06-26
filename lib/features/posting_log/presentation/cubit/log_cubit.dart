import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../domain/entities/posting_log.dart';
import '../../domain/repositories/log_repository.dart';

abstract class LogState extends Equatable {
  const LogState();
  @override
  List<Object?> get props => [];
}

class LogInitial extends LogState {
  const LogInitial();
}

class LogLoading extends LogState {
  const LogLoading();
}

class LogLoaded extends LogState {
  const LogLoaded({
    required this.logs,
    this.filterPlatform,
    this.filterStatus,
  });

  final List<PostingLog> logs;
  final SocialPlatform? filterPlatform;
  final LogStatus? filterStatus;

  List<PostingLog> get visible {
    Iterable<PostingLog> list = logs;
    if (filterPlatform != null) {
      list = list.where((l) => l.platform == filterPlatform);
    }
    if (filterStatus != null) {
      list = list.where((l) => l.status == filterStatus);
    }
    return list.toList();
  }

  LogLoaded copyWith({
    List<PostingLog>? logs,
    SocialPlatform? filterPlatform,
    LogStatus? filterStatus,
    bool clearPlatform = false,
    bool clearStatus = false,
  }) =>
      LogLoaded(
        logs: logs ?? this.logs,
        filterPlatform:
            clearPlatform ? null : (filterPlatform ?? this.filterPlatform),
        filterStatus:
            clearStatus ? null : (filterStatus ?? this.filterStatus),
      );

  @override
  List<Object?> get props => [logs, filterPlatform, filterStatus];
}

class LogError extends LogState {
  const LogError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class LogCubit extends Cubit<LogState> {
  LogCubit({required this.repository}) : super(const LogInitial()) {
    _subscribe();
  }

  final LogRepository repository;
  StreamSubscription? _sub;

  void _subscribe() {
    _sub?.cancel();
    _sub = repository.watchAllLogs().listen((logs) {
      final s = state;
      if (s is LogLoaded) {
        emit(s.copyWith(logs: logs));
      } else {
        emit(LogLoaded(logs: logs));
      }
    });
  }

  Future<void> loadForPost(String postId) async {
    emit(const LogLoading());
    _sub?.cancel();
    _sub = repository.watchLogsForPost(postId).listen((logs) {
      final s = state;
      if (s is LogLoaded) {
        emit(s.copyWith(logs: logs));
      } else {
        emit(LogLoaded(logs: logs));
      }
    });
  }

  void filterByPlatform(SocialPlatform? p) {
    final s = state;
    if (s is LogLoaded) {
      emit(p == null
          ? s.copyWith(clearPlatform: true)
          : s.copyWith(filterPlatform: p));
    }
  }

  void filterByStatus(LogStatus? st) {
    final s = state;
    if (s is LogLoaded) {
      emit(st == null
          ? s.copyWith(clearStatus: true)
          : s.copyWith(filterStatus: st));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
