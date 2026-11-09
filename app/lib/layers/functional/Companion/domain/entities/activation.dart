import 'dart:math';

class ActivationRound {
  const ActivationRound({this.units = const [], this.done = const {}});

  final List<String> units;
  final Set<int> done;

  List<int> get remaining => [
    for (var i = 0; i < units.length; i++)
      if (!done.contains(i)) i,
  ];

  bool get finished => units.isNotEmpty && remaining.isEmpty;

  ActivationRound add(String name) {
    final clean = name.trim();
    if (clean.isEmpty || units.contains(clean)) return this;
    return ActivationRound(units: [...units, clean], done: done);
  }

  ActivationRound remove(int index) => ActivationRound(
    units: [
      for (final (i, u) in units.indexed)
        if (i != index) u,
    ],
    done: {
      for (final d in done)
        if (d != index) d > index ? d - 1 : d,
    },
  );

  ActivationRound toggle(int index) => ActivationRound(
    units: units,
    done: done.contains(index) ? ({...done}..remove(index)) : {...done, index},
  );

  int? draw(Random random) {
    final left = remaining;
    return left.isEmpty ? null : left[random.nextInt(left.length)];
  }

  ActivationRound newRound() => ActivationRound(units: units);
}
