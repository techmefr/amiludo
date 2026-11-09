class Bracket {
  const Bracket(this.rounds);

  factory Bracket.seed(List<String> names) {
    var size = 2;
    while (size < names.length) {
      size *= 2;
    }
    final first = <String?>[
      for (var i = 0; i < size; i++) i < names.length ? names[i] : null,
    ];
    final rounds = <List<String?>>[first];
    while (rounds.last.length > 1) {
      rounds.add(List<String?>.filled(rounds.last.length ~/ 2, null));
    }
    return Bracket(_advanceByes(rounds));
  }

  final List<List<String?>> rounds;

  String? get champion => rounds.last.first;

  int matches(int round) => rounds[round].length ~/ 2;

  (String?, String?) pairing(int round, int match) =>
      (rounds[round][match * 2], rounds[round][match * 2 + 1]);

  bool decided(int round, int match) => rounds[round + 1][match] != null;

  Bracket win(int round, int match, int side) {
    final winner = rounds[round][match * 2 + side];
    if (round + 1 >= rounds.length || winner == null) return this;
    final next = [
      for (final r in rounds) [...r],
    ];
    next[round + 1][match] = winner;
    for (var r = round + 2; r < next.length; r++) {
      next[r] = List<String?>.filled(next[r].length, null);
    }
    return Bracket(_advanceByes(next));
  }
}

List<List<String?>> _advanceByes(List<List<String?>> rounds) {
  for (var r = 0; r + 1 < rounds.length; r++) {
    for (var m = 0; m < rounds[r].length ~/ 2; m++) {
      final a = rounds[r][m * 2], b = rounds[r][m * 2 + 1];
      if (r == 0 && (a == null) != (b == null)) {
        rounds[r + 1][m] = a ?? b;
      }
    }
  }
  return rounds;
}
