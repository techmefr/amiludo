import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';

class CharacterDraft {
  CharacterDraft(
    this.categories, {
    this.packName = '',
    this.boosters = true,
    RandomTools? random,
  }) : offers = [
         for (final c in categories)
           boosters
               ? (random ?? RandomTools())
                     .shuffled(c.cards)
                     .take(c.draw)
                     .toList()
               : c.cards,
       ];

  CharacterDraft._restored(
    this.categories,
    this.packName,
    this.boosters,
    this.offers,
    this.index,
    Map<String, List<CharacterCard>> choices,
  ) {
    this.choices.addAll(choices);
  }

  factory CharacterDraft.fromJson(Map<String, dynamic> j) {
    List<CharacterCard> cards(Object? v) => (v as List)
        .map((c) => CharacterCard.fromJson(Map<String, dynamic>.from(c as Map)))
        .toList();
    final categories = (j['categories'] as List)
        .map(
          (c) => CreationCategory.fromJson(Map<String, dynamic>.from(c as Map)),
        )
        .toList();
    final offers = (j['offers'] as List).map(cards).toList();
    final index = j['index'] as int;
    final choices = (j['choices'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, cards(v)),
    );
    if (offers.length != categories.length ||
        index < 0 ||
        index > categories.length ||
        choices.length != index) {
      throw const FormatException('Brouillon invalide');
    }
    return CharacterDraft._restored(
      categories,
      j['packName'] as String,
      j['boosters'] as bool,
      offers,
      index,
      choices,
    );
  }

  final List<CreationCategory> categories;
  final String packName;
  final bool boosters;
  final List<List<CharacterCard>> offers;
  final Map<String, List<CharacterCard>> choices = {};
  int index = 0;
  bool get complete => index >= categories.length;

  Map<String, Object?> toJson() => {
    'packName': packName,
    'boosters': boosters,
    'index': index,
    'categories': categories.map((c) => c.toJson()).toList(),
    'offers': offers.map((o) => o.map((c) => c.toJson()).toList()).toList(),
    'choices': choices.map(
      (k, v) => MapEntry(k, v.map((c) => c.toJson()).toList()),
    ),
  };

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
