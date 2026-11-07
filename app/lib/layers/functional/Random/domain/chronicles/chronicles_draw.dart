import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_card.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_rules.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';

class ChroniclesDraw {
  const ChroniclesDraw(this.data, this.random);
  final ChroniclesData data;
  final RandomTools random;

  static const boosterSize = 5;

  List<ChroniclesCard> booster({
    required String universe,
    required int stepIndex,
    required ChroniclesEdition edition,
    required List<KeptCard> kept,
    Set<String> seen = const {},
    int size = boosterSize,
  }) {
    final step = data.step(stepIndex);
    final pool = ChroniclesRules.available(
      step,
      data.poolFor(universe, step.id),
      kept,
    );
    final drawn = <ChroniclesCard>[];
    while (drawn.length < size) {
      final open = [
        for (final c in pool)
          if (!drawn.contains(c) && !_exhausted(step, c.type, drawn)) c,
      ];
      if (open.isEmpty) break;
      final fresh = open.where((c) => !seen.contains(c.id)).toList();
      final source = fresh.isEmpty ? open : fresh;
      final rarity = _rarityPresent(source);
      final candidates = source.where((c) => c.rarity == rarity).toList();
      drawn.add(
        random.weighted(candidates, [
          for (final c in candidates) _weight(step, c, edition, kept, drawn),
        ]),
      );
    }
    return drawn;
  }

  bool _exhausted(
    ChroniclesStep step,
    String type,
    List<ChroniclesCard> drawn,
  ) => step.quotaOf(type)?.max == 1 && drawn.any((c) => c.type == type);

  String _rarityPresent(List<ChroniclesCard> source) {
    final present = source.map((c) => c.rarity).toSet();
    final ids = data.rarities.map((r) => r.id).toList();
    final chosen = random.weighted(ids, [
      for (final r in data.rarities) r.weight,
    ]);
    if (present.contains(chosen)) return chosen;
    final at = ids.indexOf(chosen);
    for (var i = at - 1; i >= 0; i--) {
      if (present.contains(ids[i])) return ids[i];
    }
    for (var i = at + 1; i < ids.length; i++) {
      if (present.contains(ids[i])) return ids[i];
    }
    return source.first.rarity;
  }

  int _weight(
    ChroniclesStep step,
    ChroniclesCard card,
    ChroniclesEdition edition,
    List<KeptCard> kept,
    List<ChroniclesCard> drawn,
  ) {
    var weight = 1.0;
    if (card.favors(edition.stats)) weight *= 2;
    final quota = step.quotaOf(card.type);
    if (quota != null &&
        ChroniclesRules.count(kept, step.id, card.type) < quota.min) {
      weight *= 3;
    }
    weight /= 1 + 2 * drawn.where((c) => c.type == card.type).length;
    final scaled = (weight * 1000).round();
    return scaled < 1 ? 1 : scaled;
  }

  List<KeptCard> destiny({
    required String universe,
    required int stepIndex,
    required List<KeptCard> kept,
  }) {
    final step = data.step(stepIndex);
    final pool = data.poolFor(universe, step.id);
    final added = <KeptCard>[];
    while (true) {
      final current = [...kept, ...added];
      final missing = ChroniclesRules.missing(step, pool, current);
      if (missing.isEmpty) return added;
      final open = ChroniclesRules.available(
        step,
        pool,
        current,
      ).where((c) => c.type == missing.first.type).toList();
      final common = open.where((c) => data.rarity(c.rarity).score <= 2);
      final source = common.isEmpty ? open : common.toList();
      added.add(KeptCard(random.shuffled(source).first, destiny: true));
    }
  }
}
