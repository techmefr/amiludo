import '../../Templates/domain/character_pack.dart';
import 'random_tools.dart';

class CharacterDraft {
  CharacterDraft(this.categories, {this.boosters = true, RandomTools? random})
    : offers = [
        for (final c in categories)
          boosters
              ? (random ?? RandomTools())
                    .shuffled(c.cards)
                    .take(c.draw)
                    .toList()
              : c.cards,
      ];
  final List<CreationCategory> categories;
  final bool boosters;
  final List<List<CharacterCard>> offers;
  final Map<String, List<CharacterCard>> choices = {};
  int index = 0;
  bool get complete => index >= categories.length;
  void choose(Set<int> selected) {
    if (complete) throw StateError('Création terminée');
    final c = categories[index];
    if (selected.length < c.keepMin ||
        selected.length > c.keepMax ||
        selected.any((i) => i < 0 || i >= offers[index].length)) {
      throw const FormatException('Nombre de cartes conservées invalide');
    }
    choices[c.name] = selected.map((i) => offers[index][i]).toList();
    index++;
  }
}
