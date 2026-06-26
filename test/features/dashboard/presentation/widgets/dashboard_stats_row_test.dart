import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialbox/app/theme/app_theme.dart';
import 'package:socialbox/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:socialbox/features/dashboard/presentation/widgets/dashboard_stats_row.dart';

DashboardStats _sampleStats() => const DashboardStats(
      totalPosts: 42,
      draftPosts: 5,
      scheduledPosts: 8,
      postedPosts: 27,
      failedPosts: 2,
      totalCommentCategories: 12,
      totalComments: 156,
      totalCopies: 89,
      totalLogs: 33,
      upcomingPosts: [],
      upcomingReminders: [],
      recentActivity: [],
      platformCounts: {'linkedin': 10, 'twitter': 5},
    );

Future<void> _pumpStatsRow(
  WidgetTester tester, {
  required DashboardStats stats,
  required double width,
}) async {
  await tester.binding.setSurfaceSize(Size(width, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: MediaQuery(
        data: MediaQueryData(size: Size(width, 900)),
        child: Scaffold(
          body: SizedBox(
            width: width,
            child: DashboardStatsRow(stats: stats),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('does not overflow at 320px width', (tester) async {
    await _pumpStatsRow(tester, stats: _sampleStats(), width: 320);

    expect(tester.takeException(), isNull);
    expect(find.text('Metrics'), findsOneWidget);
    expect(find.text('Posts'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('shows horizontal stat cards', (tester) async {
    await _pumpStatsRow(tester, stats: _sampleStats(), width: 360);

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Posts'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Logs'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Logs'), findsOneWidget);
    expect(find.text('33'), findsOneWidget);
  });
}