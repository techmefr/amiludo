import 'dart:math';

const soloActions = ['gather', 'attack', 'build', 'defend', 'expand', 'trade'];
const soloLevels = [0, 1, 2];

class SoloDeck {
  const SoloDeck(this.pile, [this.drawn = const []]);

  factory SoloDeck.shuffled(Random random) =>
      SoloDeck([...soloActions, ...soloActions]..shuffle(random));

  final List<String> pile, drawn;

  String? get current => drawn.isEmpty ? null : drawn.last;

  SoloDeck draw(Random random) {
    final source = pile.isEmpty
        ? ([...soloActions, ...soloActions]..shuffle(random))
        : pile;
    final kept = pile.isEmpty ? const <String>[] : drawn;
    return SoloDeck(source.sublist(1), [...kept, source.first]);
  }
}
