import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Rules/domain/entities/rule_book.dart';
import 'package:amiludo/layers/functional/Rules/presentation/rules_tool.dart';

Widget host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  final at = DateTime.utc(2026, 11, 8, 20);
  const base = RuleGame(id: 'g1', name: 'Dungeon');

  test('decisions are recorded newest first and ignore blanks', () {
    var game = base.addDecision('Can I flee?', 'Yes, on a 10', at);
    game = game.addDecision('  ', ' ', at);
    game = game.addDecision('Flanking?', 'Advantage', at);
    expect(game.decisions.map((d) => d.question), ['Flanking?', 'Can I flee?']);
    expect(game.decisions.first.at, at);
  });

  test('a decision is removed and can be searched ignoring accents', () {
    var game = base.addDecision('Fuite ?', 'Réussite automatique', at);
    expect(game.decisions.single.matches('reussite'), isTrue);
    expect(game.decisions.single.matches('zzz'), isFalse);
    game = game.removeDecision(game.decisions.single.id);
    expect(game.decisions, isEmpty);
  });

  test('decisions survive a json round trip and section edits', () {
    final game = base
        .addDecision('Q', 'R', at)
        .withSection(0, const RuleSection(title: 'T', body: 'B'));
    expect(game.decisions.length, 1);
    final back = RuleBook.fromJson(RuleBook(games: [game]).toJson());
    expect(back.games.single.decisions.single.ruling, 'R');
    expect(back.games.single.decisions.single.at, at);
  });

  testWidgets('a ruling is added from the sheet and saved', (tester) async {
    RuleBook? saved;
    await tester.pumpWidget(
      host(
        RulesTool(
          initial: const RuleBook(games: [base]),
          onChanged: (b) => saved = b,
        ),
      ),
    );
    await tester.tap(find.text('Rulings (0)'));
    await tester.pumpAndSettle();
    expect(find.text('No ruling recorded yet.'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Situation or question'),
      'Can I flee?',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'What was decided'),
      'Yes',
    );
    await tester.tap(find.text('Record the ruling'));
    await tester.pumpAndSettle();
    expect(saved!.games.single.decisions.single.question, 'Can I flee?');
    expect(find.text('Can I flee?'), findsOneWidget);
    await tester.tap(find.byTooltip('Delete ruling'));
    await tester.pumpAndSettle();
    expect(saved!.games.single.decisions, isEmpty);
  });
}
