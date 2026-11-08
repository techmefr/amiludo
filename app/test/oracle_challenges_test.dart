import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/oracle.dart';
import 'package:amiludo/layers/functional/Random/presentation/challenges_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/oracle_tool.dart';
import 'package:amiludo/layers/technical/Theme/components/playing_card.dart';

Widget _host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  test('chaos shifts the odds and the chance stays bounded', () {
    expect(oracleChance(OracleLikelihood.even, 5), 50);
    expect(oracleChance(OracleLikelihood.even, 9), 70);
    expect(oracleChance(OracleLikelihood.likely, 9), 95);
    expect(oracleChance(OracleLikelihood.unlikely, 1), 5);
  });

  test('rolls map to answers and doubles trigger events', () {
    const even = OracleLikelihood.even;
    expect(judgeOracle(30, even, 5).answer, OracleAnswer.yes);
    expect(judgeOracle(80, even, 5).answer, OracleAnswer.no);
    expect(judgeOracle(5, even, 5).answer, OracleAnswer.exceptionalYes);
    expect(judgeOracle(98, even, 5).answer, OracleAnswer.exceptionalNo);
    expect(judgeOracle(33, even, 5).event, isTrue);
    expect(judgeOracle(66, even, 5).event, isFalse);
    expect(judgeOracle(33, even, 2).event, isFalse);
    expect(judgeOracle(100, even, 9).event, isFalse);
    expect(judgeOracle(30, even, 5).positive, isTrue);
  });

  testWidgets('the oracle gives an answer', (tester) async {
    await tester.pumpWidget(_host(OracleTool(random: Random(4))));
    await tester.tap(find.text('Ask the oracle'));
    await tester.pump();
    final answers = [
      'Yes',
      'No',
      'Yes, and more',
      'No, and worse',
    ].where((a) => find.text(a).evaluate().isNotEmpty);
    expect(answers.length, 1);
  });

  test('dare lines ignore blanks', () {
    expect(challengeLines(' a \n\n b\n'), ['a', 'b']);
  });

  testWidgets('a dare is drawn from the list', (tester) async {
    await tester.pumpWidget(_host(ChallengesTool(random: Random(1))));
    await tester.enterText(find.byType(TextField), 'Dance\nSing');
    await tester.tap(find.text('Draw a dare'));
    await tester.pumpAndSettle();
    final card = tester.widget<PlayingCard>(find.byType(PlayingCard));
    expect([Dance, Sing], contains(card.label));
  });
}
