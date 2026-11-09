const clockSizes = [4, 6, 8, 12];

class ProgressClock {
  const ProgressClock(this.name, this.segments, [this.filled = 0]);
  final String name;
  final int segments, filled;

  bool get full => filled >= segments;

  ProgressClock step(int delta) =>
      ProgressClock(name, segments, (filled + delta).clamp(0, segments));
}

List<ProgressClock> addClock(
  List<ProgressClock> clocks,
  String name,
  int segments,
) {
  final clean = name.trim();
  if (clean.isEmpty) return clocks;
  return [...clocks, ProgressClock(clean, segments)];
}

List<ProgressClock> stepClock(
  List<ProgressClock> clocks,
  int index,
  int delta,
) => [
  for (final (i, c) in clocks.indexed) i == index ? c.step(delta) : c,
];

List<ProgressClock> removeClock(List<ProgressClock> clocks, int index) => [
  for (final (i, c) in clocks.indexed)
    if (i != index) c,
];
