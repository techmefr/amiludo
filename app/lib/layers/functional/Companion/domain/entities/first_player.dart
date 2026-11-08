import 'dart:math';

int drawFirstPlayer(int count, Random random) => random.nextInt(count);

List<int> spinSequence(int count, int target, {int start = 0, int laps = 2}) {
  final distance = (target - start) % count;
  return [
    for (var step = 0; step <= laps * count + distance; step++)
      (start + step) % count,
  ];
}

({int from, int to, double fraction}) spinAt(List<int> sequence, double t) {
  final span = sequence.length - 1;
  if (span <= 0) return (from: sequence.first, to: sequence.first, fraction: 0);
  final position = t.clamp(0.0, 1.0) * span;
  final index = position.floor().clamp(0, span - 1);
  return (
    from: sequence[index],
    to: sequence[index + 1],
    fraction: (position - index).clamp(0.0, 1.0),
  );
}
