import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:socialbox/core/errors/failures.dart';
import 'package:socialbox/core/services/clipboard_service.dart';
import 'package:socialbox/core/usecases/usecase.dart';
import 'package:socialbox/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:socialbox/features/dashboard/domain/usecases/get_dashboard_stats.dart';
import 'package:socialbox/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class MockGetDashboardStats extends Mock implements GetDashboardStats {}

class MockClipboardService extends Mock implements ClipboardService {}

DashboardStats _stats({
  int totalPosts = 1,
  int scheduledPosts = 0,
}) =>
    DashboardStats(
      totalPosts: totalPosts,
      draftPosts: 0,
      scheduledPosts: scheduledPosts,
      postedPosts: 0,
      failedPosts: 0,
      totalCommentCategories: 0,
      totalComments: 0,
      totalCopies: 0,
      totalLogs: 0,
      upcomingPosts: const [],
      upcomingReminders: const [],
      recentActivity: const [],
      platformCounts: const {},
    );

void main() {
  late MockGetDashboardStats getStats;
  late MockClipboardService clipboard;
  late DashboardCubit cubit;

  setUp(() {
    getStats = MockGetDashboardStats();
    clipboard = MockClipboardService();
    registerFallbackValue(const NoParams());
  });

  DashboardCubit buildCubit() => DashboardCubit(
        getStats: getStats,
        clipboard: clipboard,
      );

  group('DashboardCubit', () {
    blocTest<DashboardCubit, DashboardState>(
      'emits Loading then Loaded on initial load',
      build: () {
        when(() => getStats(any()))
            .thenAnswer((_) async => Right(_stats()));
        return buildCubit();
      },
      act: (c) => c.load(),
      expect: () => [
        const DashboardLoading(),
        DashboardLoaded(_stats()),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits DashboardError on initial load failure',
      build: () {
        when(() => getStats(any())).thenAnswer(
          (_) async => const Left(DatabaseFailure(message: 'db error')),
        );
        return buildCubit();
      },
      act: (c) => c.load(),
      expect: () => [
        const DashboardLoading(),
        const DashboardError('db error'),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'sets isRefreshing during reload without emitting Loading',
      build: () {
        when(() => getStats(any()))
            .thenAnswer((_) async => Right(_stats(scheduledPosts: 2)));
        return buildCubit();
      },
      seed: () => DashboardLoaded(_stats()),
      act: (c) => c.load(),
      expect: () => [
        DashboardLoaded(_stats(), isRefreshing: true),
        DashboardLoaded(_stats(scheduledPosts: 2)),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'clears isRefreshing and keeps stats on refresh failure',
      build: () {
        when(() => getStats(any())).thenAnswer(
          (_) async => const Left(DatabaseFailure(message: 'db error')),
        );
        return buildCubit();
      },
      seed: () => DashboardLoaded(_stats()),
      act: (c) => c.load(),
      expect: () => [
        DashboardLoaded(_stats(), isRefreshing: true),
        DashboardLoaded(_stats(), isRefreshing: false),
      ],
    );

    test('ignores stale responses from overlapping load calls', () async {
      var callCount = 0;
      when(() => getStats(any())).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return Right(_stats(totalPosts: 1));
        }
        return Right(_stats(totalPosts: 99));
      });

      cubit = buildCubit();
      cubit.emit(DashboardLoaded(_stats(totalPosts: 5)));

      final first = cubit.load();
      final second = cubit.load();
      await Future.wait([first, second]);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(cubit.state, DashboardLoaded(_stats(totalPosts: 99)));
      await cubit.close();
    });
  });
}