class CountdownState {
  const CountdownState({
    required this.total,
    required this.remaining,
    this.running = false,
  });

  factory CountdownState.of(Duration total) =>
      CountdownState(total: total, remaining: total);

  static const Duration longest = Duration(hours: 3);
  static const Duration step = Duration(seconds: 30);

  final Duration total, remaining;
  final bool running;

  bool get finished => remaining == Duration.zero;
  bool get pristine => !running && remaining == total;
  double get fraction => total == Duration.zero
      ? 0
      : remaining.inMilliseconds / total.inMilliseconds;

  CountdownState tick(Duration elapsed) {
    if (!running) return this;
    final left = remaining - elapsed;
    final next = left > Duration.zero ? left : Duration.zero;
    return CountdownState(
      total: total,
      remaining: next,
      running: next > Duration.zero,
    );
  }

  CountdownState toggled() {
    if (finished) return CountdownState.of(total).copyRunning(true);
    return copyRunning(!running);
  }

  CountdownState copyRunning(bool value) =>
      CountdownState(total: total, remaining: remaining, running: value);

  CountdownState reset() => CountdownState.of(total);

  CountdownState adjusted(Duration delta) {
    if (running) return this;
    final next = total + delta;
    if (next < step || next > longest) return this;
    return CountdownState.of(next);
  }
}
