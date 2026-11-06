import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/counter.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/tool_catalog.dart';

const counterBrickPrefix = 'counter-';

const brickCategories = [
  'all',
  'favorites',
  'counters',
  'chance',
  'match',
  'time',
  'story',
];

class BrickEntry {
  const BrickEntry(this.id, this.category, {this.counter});
  final String id, category;
  final CounterSettings? counter;

  bool get isCounter => counter != null;

  Brick toBrick() {
    final preset = counter;
    if (preset == null) return Brick(id: id, type: id);
    return Brick(
      id: id.substring(counterBrickPrefix.length),
      type: 'counter',
      settings: preset.toJson(),
    );
  }
}

const counterEntries = [
  BrickEntry('counter-life', 'counters', counter: lifePreset),
  BrickEntry('counter-points', 'counters', counter: pointsPreset),
  BrickEntry('counter-chips', 'counters', counter: chipsPreset),
  BrickEntry('counter-pot', 'counters', counter: potPreset),
];

final brickEntries = [
  for (final t in toolDefinitions) BrickEntry(t.id, t.category),
  ...counterEntries,
];

List<BrickEntry> filterBricks(
  Iterable<BrickEntry> entries, {
  required String category,
  required Set<String> favorites,
  required String query,
  required String Function(String id) title,
}) {
  final needle = query.trim().toLowerCase();
  return [
    for (final e in entries)
      if ((category == 'all' ||
              (category == 'favorites'
                  ? favorites.contains(e.id)
                  : e.category == category)) &&
          (needle.isEmpty || title(e.id).toLowerCase().contains(needle)))
        e,
  ];
}
