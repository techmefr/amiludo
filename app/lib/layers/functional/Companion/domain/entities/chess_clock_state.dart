class ChessClockState {
  const ChessClockState({
    required this.remaining,
    required this.increment,
    this.active,
    this.flagged,
    this.paused = false,
  });

  factory ChessClockState.start(Duration time, Duration increment) =>
      ChessClockState(remaining: [time, time], increment: increment);

  final List<Duration> remaining;
  final Duration increment;
  final int? active;
  final int? flagged;
  final bool paused;

  bool get running => active != null && flagged == null && !paused;
  bool get pristine => active == null && flagged == null;

  ChessClockState tick(Duration elapsed) {
    final side = active;
    if (!running || side == null) return this;
    final left = remaining[side] - elapsed;
    final next = [...remaining];
    next[side] = left > Duration.zero ? left : Duration.zero;
    return ChessClockState(
      remaining: next,
      increment: increment,
      active: side,
      flagged: left > Duration.zero ? null : side,
      paused: paused,
    );
  }

  ChessClockState press(int side) {
    if (flagged != null || paused) return this;
    if (active != null && active != side) return this;
    final next = [...remaining];
    if (active == side) next[side] += increment;
    return ChessClockState(
      remaining: next,
      increment: increment,
      active: 1 - side,
    );
  }

  ChessClockState togglePause() => active == null || flagged != null
      ? this
      : ChessClockState(
          remaining: remaining,
          increment: increment,
          active: active,
          paused: !paused,
        );
}

String formatClock(Duration value) {
  String two(int n) => n.toString().padLeft(2, '0');
  final minutes = value.inMinutes;
  final seconds = two(value.inSeconds.remainder(60));
  if (value < const Duration(seconds: 10)) {
    final tenth = value.inMilliseconds.remainder(1000) ~/ 100;
    return '$minutes:$seconds.$tenth';
  }
  return '${two(minutes)}:$seconds';
}
