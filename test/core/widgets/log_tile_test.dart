import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialbox/core/utils/platform_utils.dart';
import 'package:socialbox/core/widgets/log_tile.dart';
import 'package:socialbox/features/posting_log/domain/entities/posting_log.dart';

PostingLog _sampleLog({PostingMethod method = PostingMethod.manual}) {
  return PostingLog(
    id: 'log-1',
    postId: 'post-1',
    platform: SocialPlatform.linkedin,
    status: LogStatus.posted,
    method: method,
    postedAt: DateTime(2026, 6, 26, 14, 30),
    createdAt: DateTime(2026, 6, 26, 14, 30),
    notes: 'Published from mobile',
  );
}

Future<void> _pumpLogTile(
  WidgetTester tester, {
  required double width,
  PostingLog? log,
}) async {
  await tester.binding.setSurfaceSize(Size(width, 200));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          child: LogTile(
            log: log ?? _sampleLog(),
            onStatusChanged: (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('uses narrow stacked layout below 260px content width',
      (tester) async {
    // Total width 300 → Expanded content ~202px (<260), triggering narrow layout.
    await _pumpLogTile(tester, width: 300);

    expect(tester.takeException(), isNull);
    expect(find.text('LinkedIn'), findsOneWidget);
    expect(find.text('Posted'), findsOneWidget);
    expect(find.text('Manual'), findsOneWidget);

    final platformTop = tester.getTopLeft(find.text('LinkedIn')).dy;
    final methodTop = tester.getTopLeft(find.text('Manual')).dy;
    expect(methodTop, greaterThan(platformTop));
  });

  testWidgets('uses wide inline layout at sufficient width', (tester) async {
    await _pumpLogTile(
      tester,
      width: 420,
      log: _sampleLog(method: PostingMethod.api),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('LinkedIn'), findsOneWidget);
    expect(find.text('API'), findsOneWidget);

    final platformTop = tester.getTopLeft(find.text('LinkedIn')).dy;
    final methodTop = tester.getTopLeft(find.text('API')).dy;
    expect((methodTop - platformTop).abs(), lessThan(8));
  });
}