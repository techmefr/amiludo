import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/presentation/buzzer_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/stats_tool.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/play_stats.dart';

Widget host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

const names = ['Ana', 'Ben'];

GameSession played(String title, {required bool finished}) {
  var game = GameSession(
    id: title,
    title: title,
    createdAt: 1,
    players: [
      for (final (i, name) in names.indexed)
        Player(id: 'p$i', name: name, color: 0),
    ],
    categories: const ['Points'],
  );
  game = game.addScore('p0', 5, 'Points').addScore('p1', 2, 'Points');
  return finished ? game.copyWith(finishedAt: 2) : game;
}

void main() {
  test('only finished games count, with wins for the top score', () {
    final games = [
      played('Skyjo', finished: true),
      played('Skyjo', finished: true),
      played('Catan', finished: true),
      played('Open', finished: false),
    ];
    final players = playerRecords(games);
    expect(players.first.name, 'Ana');
    expect((players.first.played, players.first.wins), (3, 3));
    expect(players.last.wins, 0);
    expect(players.first.rate, 1);
    final titles = gameRecords(games);
    expect((titles.first.title, titles.first.plays), ('Skyjo', 2));
    expect(titles.length, 2);
  });

  testWidgets('statistics list players and games, or an empty hint', (
    tester,
  ) async {
    await tester.pumpWidget(host(const StatsTool(games: [])));
    expect(find.text('Finish a game to see statistics here.'), findsOneWidget);
    await tester.pumpWidget(
      host(StatsTool(games: [played('Skyjo', finished: true)])),
    );
    expect(find.text('1 wins of 1'), findsOneWidget);
    expect(find.text('0 wins of 1'), findsOneWidget);
    expect(find.text('Skyjo'), findsOneWidget);
  });

  testWidgets('the first press wins until reset', (tester) async {
    await tester.pumpWidget(host(const BuzzerTool(names: names)));
    expect(find.text('Ready, press your button'), findsOneWidget);
    await tester.tap(find.text('Ben'));
    await tester.pump();
    await tester.tap(find.text('Ana'));
    await tester.pump();
    expect(find.text('Ben pressed first'), findsOneWidget);
    await tester.tap(find.text('Reset'));
    await tester.pump();
    expect(find.text('Ready, press your button'), findsOneWidget);
  });
}
