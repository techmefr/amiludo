import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Random/presentation/teams_finger_pad.dart';
import 'package:amiludo/router.dart';

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

  testWidgets('teams are made from typed names or from fingers', (
    tester,
  ) async {
    final db = await openApp(tester);
    router.go('/tools/teams');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Léa, Sam, Alex, Zoé');
    await tester.tap(find.text('Former les équipes'));
    await tester.pumpAndSettle();
    expect(find.text('Équipe 1'), findsOneWidget);
    expect(find.text('Équipe 2'), findsOneWidget);
    await tester.tap(find.text('Au doigt'));
    await tester.pumpAndSettle();
    final pad = tester.getCenter(find.byType(TeamsFingerPad));
    final first = await tester.startGesture(pad - const Offset(80, 0));
    final second = await tester.startGesture(
      pad + const Offset(80, 0),
      pointer: 7,
    );
    await tester.pump(const Duration(seconds: 2));
    Finder onPad(String text) => find.descendant(
      of: find.byType(TeamsFingerPad),
      matching: find.text(text),
    );
    expect(onPad('1'), findsOneWidget);
    expect(onPad('2'), findsOneWidget);
    await first.up();
    await second.up();
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
