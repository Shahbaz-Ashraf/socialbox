import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialbox/features/ai_prompts/presentation/widgets/ai_app_picker_sheet.dart';

void main() {
  testWidgets('Open in AI sheet has no overflow on 320px-wide screen',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var copyCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => showAiAppPickerSheet(
                  context,
                  enabled: true,
                  onCopyAndOpen: (_) async {
                    copyCalled = true;
                  },
                ),
                child: const Text('Open sheet'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open sheet'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Open in AI'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Scroll through all AI app rows — should not overflow.
    final listView = find.byType(ListView);
    expect(listView, findsOneWidget);
    await tester.drag(listView, const Offset(0, -200));
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('ChatGPT'));
    await tester.pump();
    expect(copyCalled, isTrue);
  });

  testWidgets('Open in AI sheet respects disabled state', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => showAiAppPickerSheet(
                  context,
                  enabled: false,
                  onCopyAndOpen: (_) async {},
                ),
                child: const Text('Open sheet'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open sheet'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final tile = tester.widget<ListTile>(find.byType(ListTile).first);
    expect(tile.enabled, isFalse);
    expect(tester.takeException(), isNull);
  });
}