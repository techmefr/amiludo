import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'library_widget_test.dart' show openApp;

void main() {
  testWidgets('a night is planned locally with seats and invite fallback', (
    tester,
  ) async {
    final db = await openApp(tester);
    await tester.tap(find.text('Soirées').first);
    await tester.pumpAndSettle();
    expect(find.text('Aucune soirée prévue'), findsOneWidget);
    await tester.tap(find.text('Organiser une soirée'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Soirée Skull');
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Soirée Skull'), findsWidgets);
    expect(find.text('1/6 places'), findsOneWidget);
    expect(find.text('Mode local'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });

  testWidgets('an evening code typed in join opens the invitation', (
    tester,
  ) async {
    final db = await openApp(tester);
    await tester.tap(find.text('Rejoindre une partie'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'abcd efgh');
    await tester.tap(find.widgetWithText(FilledButton, 'Rejoindre'));
    await tester.pumpAndSettle();
    expect(find.text('Soirée introuvable'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
