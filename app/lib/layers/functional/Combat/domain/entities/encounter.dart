import 'package:amiludo/layers/functional/Combat/domain/entities/combatant.dart';

const maxGroupSize = 20;

class Encounter {
  const Encounter({this.combatants = const [], this.round = 1, this.turnId});

  factory Encounter.fromJson(Map<String, dynamic> j) => Encounter(
    combatants: [
      for (final c in j['combatants'] as List? ?? const [])
        Combatant.fromJson(Map<String, dynamic>.from(c as Map)),
    ],
    round: j['round'] as int? ?? 1,
    turnId: j['turnId'] as String?,
  );

  final List<Combatant> combatants;
  final int round;
  final String? turnId;

  bool get isEmpty => combatants.isEmpty;

  bool get started => turnId != null;

  Combatant? get current => combatants.where((c) => c.id == turnId).firstOrNull;

  List<Combatant> get ordered {
    final indexed = combatants.indexed.toList()
      ..sort((a, b) {
        final left = a.$2.initiative, right = b.$2.initiative;
        if (left != right) {
          if (left == null) return 1;
          if (right == null) return -1;
          return right.compareTo(left);
        }
        return a.$1.compareTo(b.$1);
      });
    return [for (final (_, c) in indexed) c];
  }

  bool get missingInitiative => combatants.any((c) => c.initiative == null);

  Encounter _with(List<Combatant> next, {String? turn, int? round}) =>
      Encounter(
        combatants: next,
        round: round ?? this.round,
        turnId: turn ?? turnId,
      );

  Encounter add(Combatant combatant) => _with([...combatants, combatant]);

  Encounter addGroup(Combatant model, int count) {
    final size = count.clamp(1, maxGroupSize);
    if (size == 1) return add(model);
    final stamp = int.tryParse(model.id) ?? 0;
    return _with([
      ...combatants,
      for (var i = 1; i <= size; i++)
        Combatant(
          id: '${stamp + i}',
          name: '${model.name} $i',
          initiative: model.initiative,
          bonus: model.bonus,
          hp: model.hp,
          maxHp: model.maxHp,
          player: model.player,
        ),
    ]);
  }

  Encounter update(String id, Combatant Function(Combatant) change) =>
      _with([for (final c in combatants) c.id == id ? change(c) : c]);

  Encounter remove(String id) {
    final next = [
      for (final c in combatants)
        if (c.id != id) c,
    ];
    if (turnId != id) return _with(next);
    final after = _after(id);
    return Encounter(
      combatants: next,
      round: round,
      turnId: after != null && after != id ? after : null,
    );
  }

  Encounter start() {
    final first = ordered.where((c) => !c.down).firstOrNull;
    return Encounter(combatants: combatants, round: 1, turnId: first?.id);
  }

  Encounter reset() => Encounter(combatants: combatants);

  String? _after(String id) {
    final line = ordered;
    final at = line.indexWhere((c) => c.id == id);
    for (var step = 1; step <= line.length; step++) {
      final next = line[(at + step) % line.length];
      if (!next.down) return next.id;
    }
    return null;
  }

  Encounter next() {
    final id = turnId;
    if (id == null) return this;
    final line = ordered;
    final at = line.indexWhere((c) => c.id == id);
    for (var step = 1; step <= line.length; step++) {
      final index = at + step;
      final candidate = line[index % line.length];
      if (candidate.down) continue;
      final wrapped = index >= line.length;
      return Encounter(
        combatants: combatants,
        round: wrapped ? round + 1 : round,
        turnId: candidate.id,
      );
    }
    return this;
  }

  Encounter rollMissing(int Function(int sides) roll) => _with([
    for (final c in combatants)
      c.initiative == null ? c.copyWith(initiative: roll(20) + c.bonus) : c,
  ]);

  Encounter rollAll(int Function(int sides) roll) => _with([
    for (final c in combatants) c.copyWith(initiative: roll(20) + c.bonus),
  ]);

  Map<String, Object?> toJson() => {
    'combatants': [for (final c in combatants) c.toJson()],
    'round': round,
    'turnId': turnId,
  };
}
