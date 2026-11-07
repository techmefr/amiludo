import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_card.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_rules.dart';

const baseStat = 8;
const minStat = 3;
const maxStat = 24;
const legendaryBonus = 0.6;
const legendaryScore = 5;

class ChroniclesSection {
  const ChroniclesSection(this.step, this.fields);
  final ChroniclesStep step;
  final List<KeptCard> fields;
}

class ChroniclesSheet {
  const ChroniclesSheet({
    required this.universe,
    required this.name,
    required this.epithet,
    required this.rarity,
    required this.stats,
    required this.sections,
    required this.kept,
    required this.labels,
    required this.portrait,
  });

  final ChroniclesUniverse universe;
  final String name, epithet;
  final ChroniclesRarity rarity;
  final Map<String, int> stats;
  final List<ChroniclesSection> sections;
  final List<KeptCard> kept;
  final Map<String, String> labels;
  final ChroniclesAppearance portrait;

  static Map<String, int> statsOf(ChroniclesData data, List<KeptCard> kept) => {
    for (final s in data.stats)
      s.id:
          (baseStat +
                  kept
                      .where((k) => !k.destiny)
                      .fold(0, (a, k) => a + (k.card.modifiers[s.id] ?? 0)))
              .clamp(minStat, maxStat)
              .toInt(),
  };

  static ChroniclesRarity rarityOf(ChroniclesData data, List<KeptCard> kept) {
    final scored = kept.where((k) => !k.destiny).toList();
    final scores = [for (final k in scored) data.rarity(k.card.rarity).score];
    var mean = scores.isEmpty
        ? data.rarities.first.score.toDouble()
        : scores.fold(0, (a, b) => a + b) / scores.length;
    if (scores.any((s) => s >= legendaryScore)) mean += legendaryBonus;
    final top = data.rarities
        .map((r) => r.score)
        .reduce((a, b) => a > b ? a : b);
    final rounded = mean.round().clamp(1, top).toInt();
    return data.rarities.firstWhere(
      (r) => r.score == rounded,
      orElse: () => data.rarities.last,
    );
  }

  static String epithetOf(
    ChroniclesData data,
    String universe,
    List<KeptCard> kept,
  ) {
    ChroniclesCard? best;
    for (final k in kept) {
      final e = k.card.epithet;
      if (e == null || k.destiny) continue;
      if (best == null ||
          data.rarity(k.card.rarity).score > data.rarity(best.rarity).score) {
        best = k.card;
      }
    }
    return best?.epithet ?? data.universe(universe).epithet;
  }

  static String? _first(List<KeptCard> kept, String type) =>
      kept.where((k) => k.card.type == type).firstOrNull?.card.name;

  static ChroniclesAppearance portraitOf(List<KeptCard> kept) {
    String? pick(String? Function(ChroniclesAppearance a) read) => kept
        .map((k) => k.card.appearance)
        .whereType<ChroniclesAppearance>()
        .map(read)
        .whereType<String>()
        .firstOrNull;
    return ChroniclesAppearance(
      skin: pick((a) => a.skin),
      eyes: pick((a) => a.eyes),
      eyes2: pick((a) => a.eyes2),
      hair: pick((a) => a.hair),
      build: pick((a) => a.build),
    );
  }

  factory ChroniclesSheet.build(
    ChroniclesData data,
    String universe,
    List<KeptCard> kept,
  ) {
    final nickname = _first(kept, 'surnom');
    final base = _first(kept, 'nom') ?? '';
    return ChroniclesSheet(
      universe: data.universe(universe),
      name: nickname == null ? base : '$base « $nickname »',
      epithet: epithetOf(data, universe, kept),
      rarity: rarityOf(data, kept),
      stats: statsOf(data, kept),
      sections: [
        for (final step in data.steps)
          ChroniclesSection(step, [
            for (final q in step.quotas)
              for (final k in kept)
                if (k.card.step == step.id && k.card.type == q.type) k,
          ]),
      ],
      kept: kept,
      labels: {for (final k in kept) k.card.id: data.labelOf(k.card)},
      portrait: portraitOf(kept),
    );
  }
}
