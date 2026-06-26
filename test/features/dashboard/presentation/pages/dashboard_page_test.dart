import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:socialbox/core/services/clipboard_service.dart';
import 'package:socialbox/core/usecases/usecase.dart';
import 'package:socialbox/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:socialbox/features/dashboard/domain/usecases/get_dashboard_stats.dart';
import 'package:socialbox/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class MockGetDashboardStats extends Mock implements GetDashboardStats {}

class MockClipboardService extends Mock implements ClipboardService {}

/// Mirrors the app bar refresh action from dashboard_page.dart.
class _DashboardRefreshAppBarAction extends StatelessWidget {
  const _DashboardRefreshAppBarAction();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      buildWhen: (prev, next) =>
          prev is DashboardLoaded != next is DashboardLoaded ||
          (prev is DashboardLoaded &&
              next is DashboardLoaded &&
              prev.isRefreshing != next.isRefreshing),
      builder: (context, state) {
        if (state is DashboardLoaded && state.isRefreshing) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        return IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => context.read<DashboardCubit>().load(),
        );
      },
    );
  }
}

DashboardStats _emptyStats() => const DashboardStats(
      totalPosts: 1,
      draftPosts: 0,
      scheduledPosts: 0,
      postedPosts: 0,
      failedPosts: 0,
      totalCommentCategories: 0,
      totalComments: 0,
      totalCopies: 0,
      totalLogs: 0,
      upcomingPosts: [],
      upcomingReminders: [],
      recentActivity: [],
      platformCounts: {},
    );

void main() {
  late MockGetDashboardStats getStats;
  late MockClipboardService clipboard;

  setUp(() {
    getStats = MockGetDashboardStats();
    clipboard = MockClipboardService();
    registerFallbackValue(const NoParams());
  });

  testWidgets('shows app bar spinner when dashboard isRefreshing', (tester) async {
    final cubit = DashboardCubit(
      getStats: getStats,
      clipboard: clipboard,
    );
    cubit.emit(DashboardLoaded(_emptyStats(), isRefreshing: true));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DashboardCubit>.value(
          value: cubit,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('SocialBox'),
              actions: const [_DashboardRefreshAppBarAction()],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsNothing);

    await cubit.close();
  });

  testWidgets('shows refresh icon when dashboard is not refreshing',
      (tester) async {
    final cubit = DashboardCubit(
      getStats: getStats,
      clipboard: clipboard,
    );
    cubit.emit(DashboardLoaded(_emptyStats()));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DashboardCubit>.value(
          value: cubit,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('SocialBox'),
              actions: const [_DashboardRefreshAppBarAction()],
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await cubit.close();
  });
}