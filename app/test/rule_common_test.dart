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

const shared = RuleSection(title: 'Flanking', body: 'Advantage when flanked');
const book = RuleBook(
  games: [RuleGame(id: 'g1', name: 'Dungeon'), RuleGame(id: 'g2', name: 'Pirates')],
  common: [shared],
);

void main() {
  test('common rules are kept apart from the games and edited as a game', () {
    var next = book.put(
      book.commonGame.withSection(
        1,
        const RuleSection(title: 'Falling', body: '1d6 per 3 m'),
      ),
    );
    expect(next.common.length, 2);
    expect(next.games.length, 2);
    expect(next.of(commonRuleId)!.sections.last.title, 'Falling');
    next = next.remove('g1');
    expect(next.games.single.id, 'g2');
    expect(next.common.length, 2);
  });

  test('common rules count for a non empty book and survive json', () {
    expect(const RuleBook(common: [shared]).isEmpty, isFalse);
    expect(const RuleBook().isEmpty, isTrue);
    final back = RuleBook.fromJson(book.toJson());
    expect(back.common.single.title, 'Flanking');
    expect(back.games.length, 2);
  });

  test('an old book without common rules still loads', () {
    final back = RuleBook.fromJson({'rules': []});
    expect(back.common, isEmpty);
  });

  testWidgets('common rules show in every game and edit under their chip', (
    tester,
  ) async {
    RuleBook? saved;
    await tester.pumpWidget(
      host(RulesTool(initial: book, onChanged: (b) => saved = b)),
    );
    expect(find.text('Common rules (1)'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Pirates'));
    await tester.pumpAndSettle();
    expect(find.text('Common rules (1)'), findsOneWidget);
    await tester.tap(find.text('Common rules (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Flanking'), findsOneWidget);
    await tester.tap(find.byTooltip('Delete rule'));
    await tester.pumpAndSettle();
    expect(saved!.common, isEmpty);
    expect(saved!.games.length, 2);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Common rules'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this game'), findsNothing);
  });
}
