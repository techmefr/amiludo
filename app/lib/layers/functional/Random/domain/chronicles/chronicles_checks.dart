import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';

List<String> chroniclesProblems(ChroniclesData data) {
  final problems = <String>[];
  final stats = data.stats.map((s) => s.id).toSet();
  final rarities = data.rarities.map((r) => r.id).toSet();
  final universes = data.universes.map((u) => u.id).toSet();
  final stepIds = data.steps.map((s) => s.id).toSet();
  final seen = <String>{};
  if (data.rarities.fold(0, (a, r) => a + r.weight) != 100) {
    problems.add('rarity weights must add up to 100');
  }
  for (final step in data.steps) {
    for (final q in step.quotas) {
      if (q.min < 0 || q.max < q.min || q.max < 1) {
        problems.add('step ${step.id} type ${q.type}: invalid quota');
      }
    }
  }
  for (final e in data.editions) {
    if (e.stats.length != 2 || !e.stats.every(stats.contains)) {
      problems.add('edition ${e.id}: needs two known stats');
    }
  }
  for (final c in data.cards) {
    if (!seen.add(c.id)) problems.add('${c.id}: duplicate id');
    if (!rarities.contains(c.rarity)) problems.add('${c.id}: unknown rarity');
    if (c.universe != '*' && !universes.contains(c.universe)) {
      problems.add('${c.id}: unknown universe');
    }
    if (!stepIds.contains(c.step)) {
      problems.add('${c.id}: unknown step');
    } else if (data.steps.firstWhere((s) => s.id == c.step).quotaOf(c.type) ==
        null) {
      problems.add('${c.id}: type ${c.type} not in step ${c.step}');
    }
    for (final s in c.modifiers.keys) {
      if (!stats.contains(s)) problems.add('${c.id}: unknown stat $s');
    }
  }
  return problems;
}
