class TurnTrack {
  const TurnTrack({
    required this.players,
    required this.phases,
    this.round = 1,
    this.player = 0,
    this.phase = 0,
  });

  final List<String> players, phases;
  final int round, player, phase;

  bool get lastPhase => phase >= phases.length - 1;

  TurnTrack _copy({int? round, int? player, int? phase}) => TurnTrack(
    players: players,
    phases: phases,
    round: round ?? this.round,
    player: player ?? this.player,
    phase: phase ?? this.phase,
  );

  TurnTrack advance() => lastPhase ? nextPlayer() : _copy(phase: phase + 1);

  TurnTrack nextPlayer() => player + 1 >= players.length
      ? _copy(round: round + 1, player: 0, phase: 0)
      : _copy(player: player + 1, phase: 0);

  TurnTrack withPhases(List<String> next) => TurnTrack(
    players: players,
    phases: next,
    round: round,
    player: player,
    phase: next.isEmpty ? 0 : phase.clamp(0, next.length - 1),
  );

  TurnTrack addPhase(String name) {
    final clean = name.trim();
    if (clean.isEmpty || phases.contains(clean)) return this;
    return withPhases([...phases, clean]);
  }

  TurnTrack removePhase(int index) => withPhases([
    for (final (i, name) in phases.indexed)
      if (i != index) name,
  ]);

  TurnTrack restart() => TurnTrack(players: players, phases: phases);
}
