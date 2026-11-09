class PhaseSequenceState {
  const PhaseSequenceState({
    required this.durations,
    required this.remaining,
    this.index = 0,
    this.round = 1,
    this.running = false,
  });

  factory PhaseSequenceState.of(List<Duration> durations) =>
      PhaseSequenceState(durations: durations, remaining: durations.first);

  static const int most = 6;
  static const Duration step = Duration(seconds: 30);
  static const Duration longest = Duration(minutes: 30);

  final List<Duration> durations;
  final Duration remaining;
  final int index, round;
  final bool running;

  Duration get current => durations[index];
  double get fraction => remaining.inMilliseconds / current.inMilliseconds;
  bool get pristine =>
      !running && index == 0 && round == 1 && remaining == current;

  PhaseSequenceState _copy({
    List<Duration>? durations,
    Duration? remaining,
    int? index,
    int? round,
    bool? running,
  }) => PhaseSequenceState(
    durations: durations ?? this.durations,
    remaining: remaining ?? this.remaining,
    index: index ?? this.index,
    round: round ?? this.round,
    running: running ?? this.running,
  );

  PhaseSequenceState tick(Duration elapsed) {
    if (!running) return this;
    var state = this;
    var left = elapsed;
    while (left >= state.remaining) {
      left -= state.remaining;
      state = state.next();
    }
    return state._copy(remaining: state.remaining - left);
  }

  PhaseSequenceState next() {
    final last = index == durations.length - 1;
    final to = last ? 0 : index + 1;
    return _copy(
      index: to,
      round: last ? round + 1 : round,
      remaining: durations[to],
    );
  }

  PhaseSequenceState toggled() => _copy(running: !running);

  PhaseSequenceState reset() => PhaseSequenceState.of(durations);

  PhaseSequenceState select(int phase) =>
      running ? this : _copy(index: phase, remaining: durations[phase]);

  PhaseSequenceState adjusted(Duration delta) {
    if (running) return this;
    final value = current + delta;
    if (value < step || value > longest) return this;
    final next = [...durations]..[index] = value;
    return _copy(durations: next, remaining: value);
  }

  PhaseSequenceState added() {
    if (running || durations.length >= most) return this;
    return _copy(durations: [...durations, const Duration(seconds: 60)]);
  }

  PhaseSequenceState removed() {
    if (running || durations.length <= 2) return this;
    final next = [...durations]..removeAt(index);
    final to = index >= next.length ? next.length - 1 : index;
    return _copy(durations: next, index: to, remaining: next[to]);
  }
}
