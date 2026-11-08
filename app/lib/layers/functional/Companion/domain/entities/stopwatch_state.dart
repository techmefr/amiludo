class StopwatchState {
  const StopwatchState({
    this.elapsed = Duration.zero,
    this.running = false,
    this.laps = const [],
  });
  final Duration elapsed;
  final bool running;
  final List<Duration> laps;

  bool get pristine => elapsed == Duration.zero && laps.isEmpty && !running;

  StopwatchState withElapsed(Duration value) =>
      StopwatchState(elapsed: value, running: running, laps: laps);

  StopwatchState toggled() =>
      StopwatchState(elapsed: elapsed, running: !running, laps: laps);

  StopwatchState lapped() => running
      ? StopwatchState(
          elapsed: elapsed,
          running: running,
          laps: [...laps, elapsed],
        )
      : this;

  StopwatchState reset() => const StopwatchState();

  Duration lapLength(int index) =>
      laps[index] - (index == 0 ? Duration.zero : laps[index - 1]);

  Duration get currentLap =>
      elapsed - (laps.isEmpty ? Duration.zero : laps.last);

  Duration? get fastest => _extreme((a, b) => a < b);

  Duration? get slowest => _extreme((a, b) => a > b);

  Duration? _extreme(bool Function(Duration a, Duration b) better) {
    if (laps.length < 2) return null;
    var best = lapLength(0);
    for (var i = 1; i < laps.length; i++) {
      if (better(lapLength(i), best)) best = lapLength(i);
    }
    return best;
  }
}

String formatStopwatch(Duration value) {
  String two(int n) => n.toString().padLeft(2, '0');
  final hours = value.inHours;
  final minutes = two(value.inMinutes.remainder(60));
  final seconds = two(value.inSeconds.remainder(60));
  final hundredths = two(value.inMilliseconds.remainder(1000) ~/ 10);
  return hours > 0
      ? '$hours:$minutes:$seconds.$hundredths'
      : '$minutes:$seconds.$hundredths';
}
