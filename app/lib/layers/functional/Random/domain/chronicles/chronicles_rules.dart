import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_card.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';

class KeptCard {
  const KeptCard(this.card, {this.destiny = false});
  final ChroniclesCard card;
  final bool destiny;

  factory KeptCard.fromJson(Map<String, dynamic> j, ChroniclesData data) {
    final card = data.card(j['id'] as String);
    if (card == null) throw const FormatException('Unknown card');
    return KeptCard(card, destiny: j['destiny'] as bool? ?? false);
  }

  Map<String, Object?> toJson() => {'id': card.id, 'destiny': destiny};
}

enum Refusal { quota, conflict }

abstract final class ChroniclesRules {
  static int count(List<KeptCard> kept, int step, String type) =>
      kept.where((k) => k.card.step == step && k.card.type == type).length;

  static Refusal? refusal(
    ChroniclesStep step,
    ChroniclesCard card,
    List<KeptCard> kept,
  ) {
    final quota = step.quotaOf(card.type);
    if (quota == null || count(kept, step.id, card.type) >= quota.max) {
      return Refusal.quota;
    }
    if (kept.any((k) => card.conflictsWith(k.card))) return Refusal.conflict;
    return null;
  }

  static List<ChroniclesCard> available(
    ChroniclesStep step,
    List<ChroniclesCard> pool,
    List<KeptCard> kept,
  ) {
    final keptIds = kept.map((k) => k.card.id).toSet();
    return [
      for (final c in pool)
        if (!keptIds.contains(c.id) && refusal(step, c, kept) == null) c,
    ];
  }

  static List<TypeQuota> missing(
    ChroniclesStep step,
    List<ChroniclesCard> pool,
    List<KeptCard> kept,
  ) {
    final open = available(step, pool, kept);
    return [
      for (final q in step.quotas)
        if (count(kept, step.id, q.type) < q.min &&
            open.any((c) => c.type == q.type))
          q,
    ];
  }

  static bool stepComplete(
    ChroniclesStep step,
    List<ChroniclesCard> pool,
    List<KeptCard> kept,
  ) => missing(step, pool, kept).isEmpty;
}
