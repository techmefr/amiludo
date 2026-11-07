import 'package:amiludo/layers/functional/Random/domain/entities/brick_catalog.dart';

class ToolShelf {
  const ToolShelf(this.id, this.tools);
  final String id;
  final List<String> tools;
}

const toolShelves = [
  ToolShelf('play', [
    'picker',
    'dice-tray',
    'dice',
    'wheel',
    'coin',
    'teams',
    'order',
    'number',
    'bag',
  ]),
  ToolShelf('story', ['map', 'tavern', 'town', 'place', 'weather']),
  ToolShelf('generators', [
    'npc',
    'encounter',
    'quest',
    'treasure',
    'villain',
    'magicitem',
    'dilemma',
    'rumour',
    'trait',
    'twist',
  ]),
  ToolShelf('characters', ['character', 'heroes', 'roles']),
  ToolShelf('utilities', [
    'scores',
    'hourglass',
    'timer',
    'counter-life',
    'counter-points',
    'counter-chips',
    'counter-pot',
  ]),
];

const _featuredOrder = ['dice-tray', 'hourglass', 'map', 'wheel', 'coin'];

String heroTool({required String? lastTool, required List<String> favorites}) {
  final known = brickEntries.map((e) => e.id).toSet();
  if (lastTool != null && known.contains(lastTool)) return lastTool;
  return _featuredOrder.firstWhere(
    (id) => !favorites.contains(id),
    orElse: () => _featuredOrder.first,
  );
}

List<ToolShelf> arrangeShelves({
  required List<String> favorites,
  required String hero,
}) => [
  for (final shelf in toolShelves)
    ToolShelf(shelf.id, [
      for (final id in shelf.tools)
        if (id != hero && !favorites.contains(id)) id,
    ]),
];

List<String> pinnedTools(List<String> favorites, String hero) => [
  for (final id in favorites)
    if (id != hero && brickEntries.any((e) => e.id == id)) id,
];
