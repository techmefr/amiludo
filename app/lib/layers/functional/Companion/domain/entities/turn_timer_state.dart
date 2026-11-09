class TurnTimerState {
  const TurnTimerState({
    required this.players,
    required this.perTurn,
    required this.remaining,
    this.current = 0,
    this.running = false,
    this.turns = 0,
  });

  factory TurnTimerState.of(int players, Duration perTurn) =>
      TurnTimerState(players: players, perTurn: perTurn, remaining: perTurn);

  final int players, current, turns;
  final Duration perTurn, remaining;
  final bool running;

  bool get expired => remaining == Duration.zero;
  bool get pristine => !running && turns == 0 && remaining == perTurn;
  double get fraction => remaining.inMilliseconds / perTurn.inMilliseconds;

  TurnTimerState _with({Duration? remaining, int? current, bool? running}) =>
      TurnTimerState(
        players: players,
        perTurn: perTurn,
        remaining: remaining ?? this.remaining,
        current: current ?? this.current,
        running: running ?? this.running,
        turns: turns + (current == null ? 0 : 1),
      );

  TurnTimerState tick(Duration elapsed) {
    if (!running) return this;
    final left = remaining - elapsed;
    final next = left > Duration.zero ? left : Duration.zero;
    return _with(remaining: next, running: next > Duration.zero);
  }

  TurnTimerState toggled() =>
      expired ? pass() : _with(running: !running);

  TurnTimerState pass() => _with(
    current: (current + 1) % players,
    remaining: perTurn,
    running: true,
  );

  TurnTimerState reset() => TurnTimerState.of(players, perTurn);
}
