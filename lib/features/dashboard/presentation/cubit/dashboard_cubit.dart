import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/clipboard_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import 'dashboard_state.dart';

export 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required this.getStats,
    required this.clipboard,
  }) : super(const DashboardInitial());

  final ClipboardService clipboard;

  final GetDashboardStats getStats;
  Timer? _autoTimer;
  int _loadGeneration = 0;

  Future<void> load() async {
    final current = state;
    final generation = ++_loadGeneration;

    if (current is DashboardLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else if (current is! DashboardLoading) {
      emit(const DashboardLoading());
    }

    final r = await getStats(const NoParams());
    if (generation != _loadGeneration) return;

    r.fold(
      (f) {
        if (current is DashboardLoaded) {
          emit(current.copyWith(isRefreshing: false));
        } else {
          emit(DashboardError(f.message));
        }
      },
      (s) => emit(DashboardLoaded(s)),
    );
  }

  void startAutoRefresh() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(
        const Duration(seconds: 60), (_) => load());
  }

  Future<void> copyLogUrl(BuildContext context, String url) =>
      clipboard.copyText(context, url);

  @override
  Future<void> close() {
    _autoTimer?.cancel();
    return super.close();
  }
}