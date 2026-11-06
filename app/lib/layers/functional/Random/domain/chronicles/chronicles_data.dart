import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_card.dart';

class ChroniclesStat {
  const ChroniclesStat(this.id, this.name);
  final String id, name;
}

class ChroniclesRarity {
  const ChroniclesRarity(this.id, this.name, this.weight, this.score);
  final String id, name;
  final int weight, score;
}

class TypeQuota {
  const TypeQuota(this.type, this.min, this.max);
  final String type;
  final int min, max;
}

class ChroniclesStep {
  const ChroniclesStep(this.id, this.name, this.quotas);
  final int id;
  final String name;
  final List<TypeQuota> quotas;

  TypeQuota? quotaOf(String type) =>
      quotas.where((q) => q.type == type).firstOrNull;
}

class ChroniclesEdition {
  const ChroniclesEdition(this.id, this.name, this.stats);
  final String id, name;
  final List<String> stats;
}

class ChroniclesUniverse {
  const ChroniclesUniverse(this.id, this.name, this.epithet);
  final String id, name, epithet;
}

class ChroniclesData {
  const ChroniclesData({
    required this.stats,
    required this.rarities,
    required this.steps,
    required this.editions,
    required this.universes,
    required this.shortLabels,
    required this.cards,
  });

  final List<ChroniclesStat> stats;
  final List<ChroniclesRarity> rarities;
  final List<ChroniclesStep> steps;
  final List<ChroniclesEdition> editions;
  final List<ChroniclesUniverse> universes;
  final Map<String, String> shortLabels;
  final List<ChroniclesCard> cards;

  factory ChroniclesData.fromJson(Map<String, dynamic> j) {
    List<Map<String, dynamic>> rows(String key) => (j[key] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    return ChroniclesData(
      stats: [
        for (final s in rows('caracteristiques'))
          ChroniclesStat(s['id'] as String, s['nom'] as String),
      ],
      rarities: [
        for (final r in rows('raretes'))
          ChroniclesRarity(
            r['id'] as String,
            r['nom'] as String,
            r['poids'] as int,
            r['score'] as int,
          ),
      ],
      steps: [
        for (final s in rows('etapes'))
          ChroniclesStep(s['id'] as int, s['nom'] as String, [
            for (final q in s['types'] as List)
              TypeQuota(
                (q as Map)['type'] as String,
                q['min'] as int,
                q['max'] as int,
              ),
          ]),
      ],
      editions: [
        for (final e in rows('editions'))
          ChroniclesEdition(
            e['id'] as String,
            e['nom'] as String,
            (e['stats'] as List).map((s) => s as String).toList(),
          ),
      ],
      universes: [
        for (final u in rows('univers'))
          ChroniclesUniverse(
            u['id'] as String,
            u['nom'] as String,
            u['epithete'] as String,
          ),
      ],
      shortLabels: (j['libellesCourts'] as Map).map(
        (k, v) => MapEntry(k as String, v as String),
      ),
      cards: rows('cartes').map(ChroniclesCard.fromJson).toList(),
    );
  }

  ChroniclesRarity rarity(String id) => rarities.firstWhere((r) => r.id == id);

  ChroniclesStep step(int index) => steps[index];

  ChroniclesUniverse universe(String id) =>
      universes.firstWhere((u) => u.id == id);

  ChroniclesCard? card(String id) =>
      cards.where((c) => c.id == id).firstOrNull;

  List<ChroniclesCard> poolFor(String universe, int step) => [
    for (final c in cards)
      if (c.step == step && (c.universe == universe || c.universe == '*')) c,
  ];

  String labelOf(ChroniclesCard card) =>
      card.label ?? shortLabels[card.type] ?? card.type;
}
