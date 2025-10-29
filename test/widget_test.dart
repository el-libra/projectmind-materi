import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:insightmind_app/src/app.dart';

void main() {
  testWidgets('FAB adds a Chip to the HomePage', (WidgetTester tester) async {
    // Build the app inside a ProviderScope (as the app expects).
    await tester.pumpWidget(const ProviderScope(child: InsightMindApp()));

    // The HomePage shows a description text.
    expect(find.textContaining('Simulasi Jawaban'), findsOneWidget);

    // Initially there should be no Chip widgets (no answers yet).
    expect(find.byType(Chip), findsNothing);

    // Tap the FAB (add) to open the input dialog.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Enter a value into the TextField and press OK.
    await tester.enterText(find.byType(TextField), '2');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // After tapping OK, a Chip representing the new answer should appear.
    expect(find.byType(Chip), findsOneWidget);
  });
}
