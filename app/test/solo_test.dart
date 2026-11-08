import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/solo_deck.dart';
import 'package:amiludo/layers/functional/Companion/presentation/solo_tool.dart';

void main() {
  test('the deck empties then reshuffles', () {
    final random = Random(3);
    var deck = SoloDeck.shuffled(random);
    expect(deck.pile.length, 12);
    for (var i = 0; i < 12; i++) {
      deck = deck.draw(random);
    }
    expect(deck.pile, isEmpty);
    expect(deck.drawn.length, 12);
    deck = deck.draw(random);
    expect(deck.drawn.length, 1);
    expect(deck.pile.length, 11);
    expect(soloActions, contains(deck.current));
  });

  testWidgets('drawing shows an action and the bonus', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(child: SoloTool(random: Random(1))),
        ),
      ),
    );
    expect(find.text('?'), findsOneWidget);
    await tester.tap(find.text('Draw an action'));
    await tester.pumpAndSettle();
    expect(find.text('?'), findsNothing);
    expect(find.text('+1 for the automaton'), findsOneWidget);
    expect(find.text('11 cards left'), findsOneWidget);
  });
}
