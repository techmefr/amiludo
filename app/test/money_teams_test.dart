import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/bank_ledger.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/bracket.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/team_balance.dart';
import 'package:amiludo/layers/functional/Companion/presentation/auction_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/balance_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/bank_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tournament_tool.dart';

Widget host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

const names = ['Ana', 'Ben', 'Cy'];

void main() {
  test('transfers keep the total and refuse overdrafts', () {
    var ledger = BankLedger.begin(2, start: 100);
    ledger = ledger.transfer(0, 1, 40);
    expect(ledger.balances, [60, 140]);
    expect(ledger.transfer(0, 1, 500).balances, [60, 140]);
    expect(ledger.transfer(bankIndex, 0, 500).balances, [560, 140]);
    expect(ledger.transfer(1, 1, 5), same(ledger));
  });

  test('a bracket pads with byes and crowns one champion', () {
    var bracket = Bracket.seed(['A', 'B', 'C']);
    expect(bracket.rounds.length, 3);
    expect(bracket.rounds[1][1], 'C');
    bracket = bracket.win(0, 0, 1);
    expect(bracket.rounds[1][0], 'B');
    bracket = bracket.win(1, 0, 0);
    expect(bracket.champion, 'B');
    bracket = bracket.win(0, 0, 0);
    expect(bracket.champion, isNull);
    expect(bracket.rounds[1][0], 'A');
  });

  test('teams are balanced by level', () {
    final groups = balanceTeams([5, 4, 3, 2, 1, 1]);
    int total(List<int> g, List<int> l) => g.fold(0, (s, p) => s + l[p]);
    final levels = [5, 4, 3, 2, 1, 1];
    expect(
      (total(groups[0], levels) - total(groups[1], levels)).abs(),
      lessThanOrEqualTo(1),
    );
    expect(groups.expand((g) => g).length, 6);
  });

  testWidgets('the bank moves money and undoes it', (tester) async {
    await tester.pumpWidget(host(const BankTool(names: names)));
    expect(find.text('1500'), findsNWidgets(3));
    await tester.enterText(find.byType(TextField), '200');
    await tester.tap(find.text('Transfer'));
    await tester.pump();
    expect(find.text('1700'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(find.text('1500'), findsNWidgets(3));
  });

  testWidgets('the auction raises, then sells when time is up', (tester) async {
    await tester.pumpWidget(host(const AuctionTool(names: names)));
    await tester.tap(find.text('Ben'));
    await tester.pump();
    await tester.tap(find.text('+10'));
    await tester.pump();
    expect(find.text('10'), findsOneWidget);
    await tester.pump(const Duration(seconds: 16));
    expect(find.text('Sold to Ben for 10'), findsOneWidget);
  });

  testWidgets('the tournament crowns the tapped winners', (tester) async {
    await tester.pumpWidget(host(const TournamentTool(names: ['A', 'B'])));
    await tester.tap(find.text('A').first);
    await tester.pump();
    expect(find.text('A wins the tournament'), findsOneWidget);
  });

  testWidgets('teams show their totals', (tester) async {
    await tester.pumpWidget(host(const BalanceTool(names: names)));
    expect(find.textContaining('Team 1, total'), findsOneWidget);
    await tester.tap(find.text('3 teams'));
    await tester.pump();
    expect(find.textContaining('Team 3, total'), findsOneWidget);
  });
}
