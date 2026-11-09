import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/card_deck.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/secret_vote.dart';
import 'package:amiludo/layers/functional/Random/presentation/deck_face.dart';
import 'package:amiludo/layers/functional/Random/presentation/deck_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/vote_tool.dart';
import 'package:amiludo/layers/functional/Rules/domain/entities/rule_book.dart';
import 'package:amiludo/layers/functional/Rules/presentation/rules_tool.dart';

Widget _host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  _deckTests();
  _voteTests();
  _rulesTests();
}

void _deckTests() {
  test('a standard deck holds 52 distinct cards', () {
    final cards = standardCards();
    expect(cards.length, 52);
    expect(cards.toSet().length, 52);
    expect(PlayingFace.tryParse('10♥')!.red, isTrue);
    expect(PlayingFace.tryParse('K♠')!.red, isFalse);
    expect(PlayingFace.tryParse('Dragon'), isNull);
  });

  test('custom cards honour copies and ignore blank lines', () {
    final cards = parseCards('Sun x3\n\n  Moon \nStar ×2\nx3');
    expect(cards, ['Sun', 'Sun', 'Sun', 'Moon', 'Star', 'Star', 'x3']);
  });

  test('drawing, discarding and recycling move cards between piles', () {
    var deck = CardDeck.shuffled(['a', 'b', 'c'], Random(3));
    expect(deck.pile.length, 3);
    deck = deck.draw().draw();
    expect(deck.hand.length, 2);
    expect(deck.pile.length, 1);
    final first = deck.hand.first;
    deck = deck.discardAt(0);
    expect(deck.discard, [first]);
    deck = deck.discardHand();
    expect(deck.hand, isEmpty);
    expect(deck.discard.length, 2);
    deck = deck.recycle(Random(1));
    expect(deck.pile.length, 3);
    expect(deck.discard, isEmpty);
    expect(deck.draw().draw().draw().draw().hand.length, 3);
  });

  testWidgets('the deck tool draws a face-up card', (tester) async {
    await tester.pumpWidget(_host(DeckTool(random: Random(1))));
    expect(find.textContaining('52 in the deck'), findsOneWidget);
    await tester.tap(find.text('Draw a card'));
    await tester.pumpAndSettle();
    expect(find.textContaining('51 in the deck'), findsOneWidget);
    expect(find.byType(DeckFace), findsWidgets);
    await tester.tap(find.text('My cards'));
    await tester.pumpAndSettle();
    expect(find.text('The deck is empty.'), findsOneWidget);
  });
}

void _voteTests() {
  test('a vote counts ballots and reports ties', () {
    var vote = const SecretVote(
      question: 'Who?',
      choices: ['Ann', 'Bob'],
      voters: 3,
    );
    expect(vote.winners, isEmpty);
    vote = vote.cast(0).cast(1);
    expect(vote.closed, isFalse);
    expect(vote.tied, isTrue);
    vote = vote.cast(1).cast(0);
    expect(vote.closed, isTrue);
    expect(vote.tally, [1, 2]);
    expect(vote.winners, [1]);
    expect(vote.tied, isFalse);
  });

  test('choices are trimmed, unique and capped', () {
    expect(parseChoices(' a, b ,a\nc'), ['a', 'b', 'c']);
    expect(
      parseChoices(List.generate(30, (i) => 'n$i').join(',')).length,
      maxChoices,
    );
  });

  testWidgets('voters pass the phone and the result is revealed', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const VoteTool()));
    await tester.enterText(find.byType(TextField).at(0), 'Who is it?');
    await tester.enterText(find.byType(TextField).at(1), 'Red, Blue');
    await tester.tap(find.byTooltip('Fewer voters'));
    await tester.tap(find.byTooltip('Fewer voters'));
    await tester.pump();
    await tester.tap(find.text('Start the vote'));
    await tester.pumpAndSettle();
    expect(find.text('Voter 1 of 2'), findsOneWidget);
    for (var turn = 1; turn <= 2; turn++) {
      await tester.tap(find.text('I am ready'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Red'));
      await tester.pump();
      await tester.tap(find.text('Cast my vote'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Everyone has voted.'), findsOneWidget);
    await tester.tap(find.text('Reveal the result'));
    await tester.pumpAndSettle();
    expect(find.text('2 votes'), findsOneWidget);
    expect(find.text('0 votes'), findsOneWidget);
    await tester.tap(find.text('Vote again'));
    await tester.pumpAndSettle();
    expect(find.text('Start the vote'), findsOneWidget);
  });
}

void _rulesTests() {
  test('rules are searched without caring for case or accents', () {
    const game = RuleGame(
      id: 'g',
      name: 'Jeu',
      sections: [
        RuleSection(title: 'Mise en place', body: 'Distribuer 5 cartes'),
        RuleSection(title: 'Fin', body: 'Le plus riche gagne'),
      ],
    );
    expect(game.search('DISTRIBUER'), [0]);
    expect(game.search('mise'), [0]);
    expect(game.search('Gagné'), [1]);
    expect(game.search('gagne'), [1]);
    expect(game.search(''), [0, 1]);
  });

  test('a rule book edits games and survives a round trip', () {
    var book = const RuleBook().put(const RuleGame(id: 'a', name: 'A'));
    book = book.put(
      book.of('a')!.withSection(0, const RuleSection(title: 't', body: 'b')),
    );
    book = book.put(const RuleGame(id: 'b', name: 'B'));
    expect(book.games.length, 2);
    final copy = RuleBook.fromJson(book.toJson());
    expect(copy.of('a')!.sections.single.title, 't');
    expect(copy.remove('a').games.single.id, 'b');
    expect(book.of('a')!.withoutSection(0).sections, isEmpty);
  });

  testWidgets('a game is created, written and searched', (tester) async {
    RuleBook? saved;
    await tester.pumpWidget(
      _host(
        RulesTool(
          askName: (_) async => 'Catan',
          onChanged: (book) => saved = book,
        ),
      ),
    );
    expect(find.text('No rules yet. Add a game to start.'), findsOneWidget);
    await tester.tap(find.text('New game'));
    await tester.pumpAndSettle();
    expect(saved!.games.single.name, 'Catan');
    expect(find.text('This game has no rule yet.'), findsOneWidget);
    await tester.tap(find.text('Add a rule'));
    await tester.pumpAndSettle();
    final fields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), 'Trading');
    await tester.enterText(fields.at(1), 'Swap resources with a player');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Trading'), findsOneWidget);
    expect(saved!.games.single.sections.length, 1);
    await tester.enterText(find.byType(TextField).first, 'zzz');
    await tester.pump();
    expect(find.text('No rule matches.'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'swap');
    await tester.pump();
    expect(find.text('Trading'), findsOneWidget);
  });
}
