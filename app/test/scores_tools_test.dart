import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/life_match.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/ranking.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/tally_board.dart';
import 'package:amiludo/layers/functional/Companion/presentation/life_panel_parts.dart';
import 'package:amiludo/layers/functional/Companion/presentation/life_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/ranking_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tally_tool.dart';

Widget host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

const names = ['Ana', 'Ben', 'Cy'];

void main() {
  test('life drops with commander damage and ends on poison or damage', () {
    var match = LifeMatch.begin(names);
    match = match.commanderHit(0, 1, 21);
    expect(match.players[0].life, 19);
    expect(match.players[0].crushed, isTrue);
    expect(match.players[0].out, isTrue);
    match = match.commanderHit(0, 1, 5);
    expect(match.players[0].life, 19);
    match = match.poison(1, 12);
    expect(match.players[1].poison, poisonLimit);
    expect(match.players[1].out, isTrue);
    expect(match.energy(2, -3).players[2].energy, 0);
    expect(match.life(2, -40).players[2].out, isTrue);
    expect(match.restart(start: 20).players[0].life, 20);
    expect(match.resized(5, names).players.length, 5);
  });

  test('ties share a rank and the lowest score can win', () {
    final ranking = rankPlayers(names, [10, 10, 4]);
    expect([for (final p in ranking) p.rank], [1, 1, 3]);
    expect(winners(ranking).length, 2);
    expect(ranking.first.tied, isTrue);
    expect(ranking.last.tied, isFalse);
    final golf = rankPlayers(names, [10, null, 4], lowestWins: true);
    expect(golf.first.name, 'Cy');
    expect(golf.length, 2);
  });

  test('tally counters are added once, bumped and removed per player', () {
    var board = TallyBoard.begin(['A', 'B'], ['Gold']);
    board = board.add('Wood').add('wood ').add(' ').add('Wood');
    expect(board.counters, ['Gold', 'Wood']);
    board = board.bump(1, 1, 3).bump(0, 1, 2);
    expect(board.total(1), 5);
    expect(board.value(1, 1), 3);
    board = board.remove(0);
    expect(board.counters, ['Wood']);
    expect(board.cleared().total(0), 0);
  });

  testWidgets('life panels count, undo and open the details', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: LifeTool(names: names)),
      ),
    );
    expect(find.text('40'), findsNWidgets(4));
    await tester.tap(find.byType(LifeHalf).at(1));
    await tester.pump();
    expect(find.text('41'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(find.text('41'), findsNothing);
    await tester.tap(find.byTooltip('Details for Ana'));
    await tester.pumpAndSettle();
    expect(find.text('Commander damage'), findsOneWidget);
    await tester.tap(find.byTooltip('Increase Poison'));
    await tester.pump();
    expect(find.text('1 / 10'), findsOneWidget);
  });

  testWidgets('free counters can be added and counted', (tester) async {
    await tester.pumpWidget(host(const TallyTool(names: names)));
    expect(find.text('Resources'), findsWidgets);
    await tester.tap(find.byTooltip('Increase Resources Ana'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.text('Add a counter'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Gold');
    await tester.tap(find.widgetWithText(FilledButton, 'Add a counter'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Increase Gold Ben'), findsOneWidget);
  });

  testWidgets('the ranking names the winner and flags ties', (tester) async {
    await tester.pumpWidget(host(const RankingTool(names: names)));
    expect(find.text('Enter at least one score to see the ranking.'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), '12');
    await tester.enterText(find.byType(TextField).at(1), '12');
    await tester.enterText(find.byType(TextField).at(2), '3');
    await tester.pump();
    expect(find.text('Tie'), findsWidgets);
    await tester.enterText(find.byType(TextField).at(1), '15');
    await tester.pump();
    expect(find.text('Winner'), findsOneWidget);
    expect(find.text('Ben'), findsNWidgets(2));
  });
}
