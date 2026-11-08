import 'dart:math';

const deckSuits = ['♠', '♥', '♦', '♣'];
const deckRanks = [
  'A',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '10',
  'J',
  'Q',
  'K',
];
const redSuits = {'♥', '♦'};
const maxDeckCards = 300;

final _copies = RegExp(r'\s*[x×]\s*(\d{1,2})$', caseSensitive: false);

List<String> standardCards() => [
  for (final suit in deckSuits)
    for (final rank in deckRanks) '$rank$suit',
];

List<String> parseCards(String text) {
  final cards = <String>[];
  for (final line in text.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    final match = _copies.firstMatch(trimmed);
    final name = match == null ? '' : trimmed.substring(0, match.start).trim();
    final copies = name.isEmpty ? 1 : int.parse(match![1]!);
    for (var i = 0; i < copies && cards.length < maxDeckCards; i++) {
      cards.add(name.isEmpty ? trimmed : name);
    }
  }
  return cards;
}

class PlayingFace {
  const PlayingFace(this.rank, this.suit);

  static PlayingFace? tryParse(String card) {
    if (card.length < 2) return null;
    final suit = card.substring(card.length - 1);
    final rank = card.substring(0, card.length - 1);
    if (!deckSuits.contains(suit) || !deckRanks.contains(rank)) return null;
    return PlayingFace(rank, suit);
  }

  final String rank, suit;

  bool get red => redSuits.contains(suit);
}

class CardDeck {
  const CardDeck({
    this.pile = const [],
    this.hand = const [],
    this.discard = const [],
  });

  factory CardDeck.shuffled(List<String> cards, Random random) =>
      CardDeck(pile: [...cards]..shuffle(random));

  final List<String> pile, hand, discard;

  bool get isEmpty => pile.isEmpty;

  String? get top => hand.isEmpty ? null : hand.last;

  CardDeck draw() => isEmpty
      ? this
      : CardDeck(
          pile: pile.sublist(1),
          hand: [...hand, pile.first],
          discard: discard,
        );

  CardDeck discardAt(int index) {
    if (index < 0 || index >= hand.length) return this;
    return CardDeck(
      pile: pile,
      hand: [...hand]..removeAt(index),
      discard: [...discard, hand[index]],
    );
  }

  CardDeck discardHand() =>
      CardDeck(pile: pile, discard: [...discard, ...hand]);

  CardDeck recycle(Random random) =>
      CardDeck(pile: [...pile, ...discard]..shuffle(random), hand: hand);

  CardDeck reshuffled(Random random) =>
      CardDeck(pile: [...pile]..shuffle(random), hand: hand, discard: discard);
}
