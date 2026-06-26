import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialbox/core/widgets/scrollable_bottom_sheet.dart';

void main() {
  testWidgets('showListBottomSheet has no overflow at 320px', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => showListBottomSheet<void>(
                  context: context,
                  title: 'Pick status',
                  children: List.generate(
                    8,
                    (i) => ListTile(
                      title: Text('Option $i with a longer label that wraps'),
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Pick status'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final listView = find.byType(ListView);
    await tester.drag(listView, const Offset(0, -180));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}