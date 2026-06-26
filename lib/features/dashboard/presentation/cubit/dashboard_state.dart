import 'package:equatable/equatable.dart';

import '../../domain/entities/dashboard_stats.dart';

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
  const DashboardLoaded(this.stats, {this.isRefreshing = false});

  final DashboardStats stats;
  final bool isRefreshing;

  DashboardLoaded copyWith({
    DashboardStats? stats,
    bool? isRefreshing,
  }) =>
      DashboardLoaded(
        stats ?? this.stats,
        isRefreshing: isRefreshing ?? this.isRefreshing,
      );

  @override
  List<Object?> get props => [stats, isRefreshing];
}

class DashboardError extends DashboardState {
  const DashboardError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}