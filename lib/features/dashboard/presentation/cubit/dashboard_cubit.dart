import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/usecases/get_dashboard_stats.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  const DashboardLoaded(this.stats);
  final DashboardStats stats;
  @override
  List<Object?> get props => [stats];
}

class DashboardError extends DashboardState {
  const DashboardError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({required this.getStats}) : super(const DashboardInitial());

  final GetDashboardStats getStats;
  Timer? _autoTimer;

  Future<void> load() async {
    emit(const DashboardLoading());
    final r = await getStats(const NoParams());
    r.fold(
      (f) => emit(DashboardError(f.message)),
      (s) => emit(DashboardLoaded(s)),
    );
  }

  void startAutoRefresh() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(
        const Duration(seconds: 60), (_) => load());
  }

  @override
  Future<void> close() {
    _autoTimer?.cancel();
    return super.close();
  }
}
