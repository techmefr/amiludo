import 'package:amiludo/layers/functional/Random/domain/entities/brick_catalog.dart';

class ToolShelf {
  const ToolShelf(this.id, this.tools);
  final String id;
  final List<String> tools;
}

const toolShelves = [
  ToolShelf('time', [
    'stopwatch',
    'countdown',
    'turn-timer',
    'phases',
    'metronome',
    'timer',
    'chess-clock',
    'hourglass',
  ]),
  ToolShelf('chance', ['dice-tray', 'dice', 'wheel', 'coin', 'number']),
  ToolShelf('scores', [
    'scores',
    'life',
    'tally',
    'ranking',
    'stats',
    'clocks',
    'sport',
    'bank',
    'league',
    'auction',
    'sheet',
    'counter-life',
    'counter-points',
    'counter-chips',
    'counter-pot',
  ]),
  ToolShelf('cards', ['deck', 'bag']),
  ToolShelf('rules', ['rules']),
  ToolShelf('votes', ['vote', 'impostor']),
  ToolShelf('ambience', ['ambience']),
  ToolShelf('party', ['challenges']),
  ToolShelf('map', ['map']),
  ToolShelf('story', ['journal', 'oracle', 'tavern', 'town', 'place', 'weather']),
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
  ToolShelf('characters', ['character', 'heroes']),
  ToolShelf('players', [
    'picker',
    'first-player',
    'buzzer',
    'markers',
    'tournament',
    'balance',
    'turns',
    'teams',
    'order',
    'roles',
  ]),
];

ToolShelf? toolShelf(String id) =>
    toolShelves.where((shelf) => shelf.id == id).firstOrNull;

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
