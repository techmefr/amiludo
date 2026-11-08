import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/league.dart';
import 'package:amiludo/layers/functional/Companion/presentation/league_tool.dart';

void main() {
  test('points, draws and goal difference order the table', () {
    final table = standings(3, const [
      LeagueMatch(0, 1, 2, 0),
      LeagueMatch(1, 2, 1, 1),
      LeagueMatch(0, 2, 0, 3),
    ]);
    expect([for (final s in table) s.player], [2, 0, 1]);
    expect(table.first.points, 4);
    expect(table.last.losses, 1);
  });

  testWidgets('a recorded match updates the table', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: LeagueTool(names: ['Ana', 'Ben']),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField).at(0), '3');
    await tester.enterText(find.byType(TextField).at(1), '1');
    await tester.tap(find.text('Add the match'));
    await tester.pump();
    expect(find.text('Ana 3 – 1 Ben'), findsOneWidget);
    expect(find.text('3'), findsWidgets);
  });
}
