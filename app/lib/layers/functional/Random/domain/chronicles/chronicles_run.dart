import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_card.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_draw.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_rules.dart';

enum ChroniclesPhase { edition, discover, recap, done }

class ChroniclesRun {
  ChroniclesRun(this.universe);

  final String universe;
  int stepIndex = 0;
  ChroniclesPhase phase = ChroniclesPhase.edition;
  String? edition;
  List<ChroniclesCard> booster = [];
  int position = 0;
  final List<KeptCard> kept = [];
  final Set<String> seen = {};

  factory ChroniclesRun.fromJson(Map<String, dynamic> j, ChroniclesData data) {
    ChroniclesCard card(Object? id) {
      final found = data.card(id as String);
      if (found == null) throw const FormatException('Unknown card');
      return found;
    }

    final run = ChroniclesRun(j['universe'] as String);
    data.universe(run.universe);
    run
      ..stepIndex = j['step'] as int
      ..phase = ChroniclesPhase.values.byName(j['phase'] as String)
      ..edition = j['edition'] as String?
      ..booster = (j['booster'] as List).map(card).toList()
      ..position = j['position'] as int;
    run.kept.addAll(
      (j['kept'] as List).map(
        (k) => KeptCard.fromJson(Map<String, dynamic>.from(k as Map), data),
      ),
    );
    run.seen.addAll((j['seen'] as List).map((s) => s as String));
    if (run.stepIndex < 0 ||
        run.stepIndex > data.steps.length ||
        run.position < 0 ||
        run.position > run.booster.length) {
      throw const FormatException('Invalid run');
    }
    return run;
  }

  Map<String, Object?> toJson() => {
    'universe': universe,
    'step': stepIndex,
    'phase': phase.name,
    'edition': edition,
    'booster': booster.map((c) => c.id).toList(),
    'position': position,
    'kept': kept.map((k) => k.toJson()).toList(),
    'seen': seen.toList(),
  };

  ChroniclesCard? get current =>
      phase == ChroniclesPhase.discover && position < booster.length
      ? booster[position]
      : null;

  List<ChroniclesCard> get boosterKept {
    final ids = kept.where((k) => !k.destiny).map((k) => k.card.id).toSet();
    return booster.where((c) => ids.contains(c.id)).toList();
  }

  ChroniclesStep step(ChroniclesData data) => data.step(stepIndex);

  List<ChroniclesCard> pool(ChroniclesData data) =>
      data.poolFor(universe, data.step(stepIndex).id);

  void openBooster(ChroniclesData data, ChroniclesDraw draw, String id) {
    final chosen = data.editions.firstWhere((e) => e.id == id);
    edition = chosen.id;
    booster = draw.booster(
      universe: universe,
      stepIndex: stepIndex,
      edition: chosen,
      kept: kept,
      seen: seen,
    );
    seen.addAll(booster.map((c) => c.id));
    position = 0;
    phase = booster.isEmpty ? ChroniclesPhase.recap : ChroniclesPhase.discover;
  }

  Refusal? keep(ChroniclesData data) {
    final card = current;
    if (card == null) return null;
    final refusal = ChroniclesRules.refusal(step(data), card, kept);
    if (refusal != null) return refusal;
    kept.add(KeptCard(card));
    _advance();
    return null;
  }

  void pass() {
    if (current != null) _advance();
  }

  void _advance() {
    position++;
    if (position >= booster.length) phase = ChroniclesPhase.recap;
  }

  void letDestinyComplete(ChroniclesData data, ChroniclesDraw draw) {
    kept.addAll(
      draw.destiny(universe: universe, stepIndex: stepIndex, kept: kept),
    );
    next(data);
  }

  void next(ChroniclesData data) {
    booster = [];
    position = 0;
    edition = null;
    phase = ChroniclesPhase.edition;
    while (stepIndex < data.steps.length &&
        ChroniclesRules.stepComplete(step(data), pool(data), kept)) {
      stepIndex++;
      seen.clear();
    }
    if (stepIndex >= data.steps.length) phase = ChroniclesPhase.done;
  }

  bool stepComplete(ChroniclesData data) =>
      ChroniclesRules.stepComplete(step(data), pool(data), kept);
}
