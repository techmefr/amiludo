class SportMode {
  const SportMode(
    this.id, {
    required this.start,
    required this.target,
    this.countdown = false,
    this.overshootTo,
  });
  final String id;
  final int start, target;
  final bool countdown;
  final int? overshootTo;

  int apply(int current, int points) {
    final next = countdown ? current - points : current + points;
    if (countdown) return next < target ? current : next;
    if (next > target) return overshootTo ?? next;
    return next;
  }

  bool won(int score) => countdown ? score == target : score >= target;
}

const sportModes = [
  SportMode('molkky', start: 0, target: 50, overshootTo: 25),
  SportMode('darts', start: 501, target: 0, countdown: true),
  SportMode('petanque', start: 0, target: 13),
];

SportMode sportMode(String id) =>
    sportModes.firstWhere((m) => m.id == id, orElse: () => sportModes.first);
