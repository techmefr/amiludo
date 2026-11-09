const poisonLimit = 10;
const commanderLimit = 21;
const maxLifePlayers = 6;
const minLifePlayers = 2;
const lifeStarts = [20, 30, 40, 50];

class LifePlayer {
  const LifePlayer({
    required this.name,
    required this.life,
    this.poison = 0,
    this.energy = 0,
    this.commander = const {},
  });
  final String name;
  final int life, poison, energy;
  final Map<int, int> commander;

  bool get poisoned => poison >= poisonLimit;

  bool get crushed => commander.values.any((hit) => hit >= commanderLimit);

  bool get out => life <= 0 || poisoned || crushed;

  LifePlayer copy({
    int? life,
    int? poison,
    int? energy,
    Map<int, int>? commander,
  }) => LifePlayer(
    name: name,
    life: life ?? this.life,
    poison: poison ?? this.poison,
    energy: energy ?? this.energy,
    commander: commander ?? this.commander,
  );
}

class LifeMatch {
  const LifeMatch(this.players, {this.start = 40});

  factory LifeMatch.begin(List<String> names, {int start = 40}) => LifeMatch([
    for (final name in names) LifePlayer(name: name, life: start),
  ], start: start);

  final List<LifePlayer> players;
  final int start;

  LifeMatch _with(int index, LifePlayer player) => LifeMatch([
    for (final (i, p) in players.indexed) i == index ? player : p,
  ], start: start);

  LifeMatch resetPlayer(int index) =>
      _with(index, LifePlayer(name: players[index].name, life: start));

  LifeMatch life(int index, int delta) =>
      _with(index, players[index].copy(life: players[index].life + delta));

  LifeMatch poison(int index, int delta) => _with(
    index,
    players[index].copy(
      poison: (players[index].poison + delta).clamp(0, poisonLimit),
    ),
  );

  LifeMatch energy(int index, int delta) => _with(
    index,
    players[index].copy(energy: (players[index].energy + delta).clamp(0, 999)),
  );

  LifeMatch commanderHit(int target, int source, int delta) {
    final player = players[target];
    final current = player.commander[source] ?? 0;
    final next = (current + delta).clamp(0, commanderLimit);
    if (next == current) return this;
    return _with(
      target,
      player.copy(
        life: player.life - (next - current),
        commander: {...player.commander, source: next},
      ),
    );
  }

  LifeMatch restart({int? start}) => LifeMatch.begin([
    for (final p in players) p.name,
  ], start: start ?? this.start);

  LifeMatch resized(int count, List<String> names) => LifeMatch.begin([
    for (var i = 0; i < count; i++) names[i % names.length],
  ], start: start);
}
