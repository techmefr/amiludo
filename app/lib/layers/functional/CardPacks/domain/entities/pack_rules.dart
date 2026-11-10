import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';

enum RevealMode { hidden, live }

enum RulesIssue {
  noPlayers,
  noDecks,
  poolTooSmall,
  keepAbovePack,
  keepInvalid,
}

class PoolDeck {
  const PoolDeck({required this.name, required this.cards});

  final String name;
  final List<CharacterCard> cards;

  Map<String, Object?> toJson() => {
    'name': name,
    'cards': [for (final c in cards) c.toJson()],
  };

  factory PoolDeck.fromJson(Map<String, dynamic> j) => PoolDeck(
    name: j['name'] as String,
    cards: [
      for (final c in j['cards'] as List)
        CharacterCard.fromJson(Map<String, dynamic>.from(c as Map)),
    ],
  );
}

class PackRules {
  const PackRules({
    this.cardsPerPack = 4,
    this.packsPerPlayer = 1,
    this.keepMin = 1,
    this.keepMax = 1,
    this.duplicates = false,
    this.rerolls = 1,
    this.reveal = RevealMode.live,
  });

  final int cardsPerPack, packsPerPlayer, keepMin, keepMax, rerolls;
  final bool duplicates;
  final RevealMode reveal;

  int get cardsPerDeck => cardsPerPack * packsPerPlayer;

  PackRules copyWith({
    int? cardsPerPack,
    int? packsPerPlayer,
    int? keepMin,
    int? keepMax,
    int? rerolls,
    bool? duplicates,
    RevealMode? reveal,
  }) => PackRules(
    cardsPerPack: cardsPerPack ?? this.cardsPerPack,
    packsPerPlayer: packsPerPlayer ?? this.packsPerPlayer,
    keepMin: keepMin ?? this.keepMin,
    keepMax: keepMax ?? this.keepMax,
    duplicates: duplicates ?? this.duplicates,
    rerolls: rerolls ?? this.rerolls,
    reveal: reveal ?? this.reveal,
  );

  RulesIssue? check(List<PoolDeck> pool, int players) {
    if (players < 1) return RulesIssue.noPlayers;
    if (pool.isEmpty) return RulesIssue.noDecks;
    if (keepMin < 0 || keepMax < keepMin || keepMax < 1) {
      return RulesIssue.keepInvalid;
    }
    if (keepMax > cardsPerDeck) return RulesIssue.keepAbovePack;
    final need = duplicates ? cardsPerPack : cardsPerDeck;
    if (pool.any((d) => d.cards.length < need)) return RulesIssue.poolTooSmall;
    return null;
  }

  Map<String, Object?> toJson() => {
    'cardsPerPack': cardsPerPack,
    'packsPerPlayer': packsPerPlayer,
    'keepMin': keepMin,
    'keepMax': keepMax,
    'duplicates': duplicates,
    'rerolls': rerolls,
    'reveal': reveal.name,
  };

  factory PackRules.fromJson(Map<String, dynamic> j) => PackRules(
    cardsPerPack: (j['cardsPerPack'] as int).clamp(1, 12),
    packsPerPlayer: (j['packsPerPlayer'] as int).clamp(1, 6),
    keepMin: (j['keepMin'] as int).clamp(0, 72),
    keepMax: (j['keepMax'] as int).clamp(1, 72),
    duplicates: j['duplicates'] as bool,
    rerolls: (j['rerolls'] as int).clamp(0, 6),
    reveal: RevealMode.values.firstWhere(
      (m) => m.name == j['reveal'],
      orElse: () => RevealMode.live,
    ),
  );
}
