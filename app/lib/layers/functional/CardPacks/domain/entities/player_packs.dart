import 'package:amiludo/layers/functional/CardPacks/domain/entities/card_rarity.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/entities/pack_rules.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';

class DealtCard {
  const DealtCard(this.card, this.rarity);

  final CharacterCard card;
  final CardRarity rarity;

  Map<String, Object?> toJson() => {
    'card': card.toJson(),
    'rarity': rarity.name,
  };

  factory DealtCard.fromJson(Map<String, dynamic> j) => DealtCard(
    CharacterCard.fromJson(Map<String, dynamic>.from(j['card'] as Map)),
    CardRarity.named(j['rarity']),
  );
}

class SealedPack {
  const SealedPack({
    required this.category,
    required this.cards,
    this.opened = false,
    this.rerollsUsed = 0,
  });

  final String category;
  final List<DealtCard> cards;
  final bool opened;
  final int rerollsUsed;

  SealedPack copyWith({
    List<DealtCard>? cards,
    bool? opened,
    int? rerollsUsed,
  }) => SealedPack(
    category: category,
    cards: cards ?? this.cards,
    opened: opened ?? this.opened,
    rerollsUsed: rerollsUsed ?? this.rerollsUsed,
  );

  Map<String, Object?> toJson() => {
    'category': category,
    'cards': [for (final c in cards) c.toJson()],
    'opened': opened,
    'rerollsUsed': rerollsUsed,
  };

  factory SealedPack.fromJson(Map<String, dynamic> j) => SealedPack(
    category: j['category'] as String,
    cards: [
      for (final c in j['cards'] as List)
        DealtCard.fromJson(Map<String, dynamic>.from(c as Map)),
    ],
    opened: j['opened'] as bool? ?? false,
    rerollsUsed: j['rerollsUsed'] as int? ?? 0,
  );
}

class PlayerPacks {
  const PlayerPacks({
    required this.name,
    this.packs = const [],
    this.kept = const {},
    this.validated = false,
  });

  final String name;
  final List<SealedPack> packs;
  final Set<String> kept;
  final bool validated;

  static String key(int pack, int card) => '$pack.$card';

  int get openedCount => packs.where((p) => p.opened).length;

  bool get allOpened => packs.isNotEmpty && openedCount == packs.length;

  List<String> get categories => [
    for (final p in packs)
      if (!packs.take(packs.indexOf(p)).any((q) => q.category == p.category))
        p.category,
  ];

  int keptIn(String category) {
    var total = 0;
    for (var p = 0; p < packs.length; p++) {
      if (packs[p].category != category) continue;
      for (var c = 0; c < packs[p].cards.length; c++) {
        if (kept.contains(key(p, c))) total++;
      }
    }
    return total;
  }

  List<DealtCard> keptCards(String category) => [
    for (var p = 0; p < packs.length; p++)
      if (packs[p].category == category)
        for (var c = 0; c < packs[p].cards.length; c++)
          if (kept.contains(key(p, c))) packs[p].cards[c],
  ];

  bool isKept(int pack, int card) => kept.contains(key(pack, card));

  bool canKeep(PackRules rules, int pack, int card) =>
      isKept(pack, card) || keptIn(packs[pack].category) < rules.keepMax;

  int missing(PackRules rules) {
    var total = 0;
    for (final c in categories) {
      final gap = rules.keepMin - keptIn(c);
      if (gap > 0) total += gap;
    }
    return total;
  }

  bool ready(PackRules rules) => allOpened && missing(rules) == 0;

  PlayerPacks toggle(PackRules rules, int pack, int card) {
    if (validated || !packs[pack].opened || !canKeep(rules, pack, card)) {
      return this;
    }
    final k = key(pack, card);
    return copyWith(kept: {...kept}..toggle(k));
  }

  PlayerPacks copyWith({
    List<SealedPack>? packs,
    Set<String>? kept,
    bool? validated,
  }) => PlayerPacks(
    name: name,
    packs: packs ?? this.packs,
    kept: kept ?? this.kept,
    validated: validated ?? this.validated,
  );

  Map<String, Object?> toJson() => {
    'name': name,
    'packs': [for (final p in packs) p.toJson()],
    'kept': kept.toList()..sort(),
    'validated': validated,
  };

  factory PlayerPacks.fromJson(Map<String, dynamic> j) => PlayerPacks(
    name: j['name'] as String,
    packs: [
      for (final p in j['packs'] as List)
        SealedPack.fromJson(Map<String, dynamic>.from(p as Map)),
    ],
    kept: {for (final k in j['kept'] as List) k as String},
    validated: j['validated'] as bool? ?? false,
  );
}

extension _SetToggle on Set<String> {
  void toggle(String value) => remove(value) || add(value);
}
