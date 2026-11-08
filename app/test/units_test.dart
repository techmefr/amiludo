import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/activation.dart';
import 'package:amiludo/layers/functional/Companion/presentation/units_tool.dart';

void main() {
  test('units act once per round and a new round resets them', () {
    var round = const ActivationRound().add('A').add('B').add(' ').add('A');
    expect(round.units, ['A', 'B']);
    round = round.toggle(0);
    expect(round.remaining, [1]);
    expect(round.draw(Random(1)), 1);
    round = round.toggle(1);
    expect(round.finished, isTrue);
    expect(round.draw(Random(1)), isNull);
    expect(round.remove(0).done, {0});
    expect(round.newRound().remaining, [0, 1]);
  });

  testWidgets('units are added, marked and drawn', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(child: UnitsTool(random: Random(2))),
        ),
      ),
    );
    await tester.tap(find.text('Add a unit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Knights');
    await tester.tap(find.widgetWithText(FilledButton, 'Add a unit'));
    await tester.pumpAndSettle();
    expect(find.text('Knights'), findsOneWidget);
    await tester.tap(find.text('Draw the next unit'));
    await tester.pump();
    expect(find.text('Knights acts next'), findsOneWidget);
    await tester.tap(find.text('Knights'));
    await tester.pump();
    expect(find.text('Every unit has acted'), findsOneWidget);
  });
}
