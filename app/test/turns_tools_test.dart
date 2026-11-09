import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/first_player.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/turn_track.dart';
import 'package:amiludo/layers/functional/Companion/presentation/first_player_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/turns_tool.dart';

Widget host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

const names = ['Ana', 'Ben', 'Cy'];

void main() {
  test('phases advance, then the next player, then the next round', () {
    var track = const TurnTrack(players: names, phases: ['A', 'B']);
    track = track.advance();
    expect((track.player, track.phase, track.lastPhase), (0, 1, true));
    track = track.advance();
    expect((track.player, track.phase), (1, 0));
    track = track.nextPlayer().nextPlayer();
    expect((track.round, track.player), (2, 0));
    expect(track.restart().round, 1);
  });

  test('phases are added once and the active one stays valid', () {
    var track = const TurnTrack(
      players: names,
      phases: ['A', 'B', 'C'],
      phase: 2,
    );
    track = track.addPhase('D').addPhase(' ').addPhase('D');
    expect(track.phases, ['A', 'B', 'C', 'D']);
    expect(track.removePhase(2).removePhase(2).phases, ['A', 'B']);
    expect(track.removePhase(2).removePhase(2).phase, 1);
  });

  test('the spin ends on the drawn seat after full laps', () {
    final sequence = spinSequence(4, 1, start: 3, laps: 2);
    expect(sequence.first, 3);
    expect(sequence.last, 1);
    expect(sequence.length, 2 * 4 + 2 + 1);
    expect(spinAt(sequence, 1).to, 1);
    expect(spinAt(sequence, 1).fraction, 1);
    expect(spinAt(const [2], .5).to, 2);
    expect(drawFirstPlayer(5, Random(1)), inInclusiveRange(0, 4));
  });

  testWidgets('the turn tool walks through the phases and players', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const SingleChildScrollView(child: TurnsTool(names: names))),
    );
    expect(find.text('Round 1'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    await tester.tap(find.text('Next phase'));
    await tester.pump();
    await tester.tap(find.text('Next phase'));
    await tester.pump();
    expect(find.text('Next player'), findsOneWidget);
    await tester.tap(find.text('Next player'));
    await tester.pump();
    expect(find.text('Ben'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(find.text('Ana'), findsOneWidget);
    await tester.tap(find.text('Add a phase').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Trade');
    await tester.tap(find.widgetWithText(FilledButton, 'Add a phase'));
    await tester.pumpAndSettle();
    expect(find.text('Trade'), findsOneWidget);
  });

  testWidgets('the token lands on the drawn player and can draw again', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(FirstPlayerTool(names: names, random: Random(7))),
    );
    expect(find.textContaining('starts'), findsNothing);
    await tester.tap(find.text('Draw the first player'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    expect(find.textContaining('starts'), findsOneWidget);
    expect(find.text('Draw again'), findsOneWidget);
  });
}
