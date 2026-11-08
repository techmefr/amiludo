class TallyBoard {
  const TallyBoard({required this.players, this.counters = const [], this.values = const []});

  factory TallyBoard.begin(List<String> players, List<String> counters) =>
      TallyBoard(
        players: players,
        counters: counters,
        values: [
          for (final _ in players) [for (final _ in counters) 0],
        ],
      );

  final List<String> players, counters;
  final List<List<int>> values;

  int value(int player, int counter) => values[player][counter];

  int total(int counter) =>
      values.fold(0, (sum, row) => sum + row[counter]);

  TallyBoard bump(int player, int counter, int delta) => TallyBoard(
    players: players,
    counters: counters,
    values: [
      for (final (p, row) in values.indexed)
        p == player
            ? [
                for (final (c, v) in row.indexed)
                  c == counter ? v + delta : v,
              ]
            : row,
    ],
  );

  TallyBoard add(String name) {
    final clean = name.trim();
    if (clean.isEmpty || counters.contains(clean)) return this;
    return TallyBoard(
      players: players,
      counters: [...counters, clean],
      values: [
        for (final row in values) [...row, 0],
      ],
    );
  }

  TallyBoard remove(int counter) => TallyBoard(
    players: players,
    counters: [
      for (final (c, name) in counters.indexed)
        if (c != counter) name,
    ],
    values: [
      for (final row in values)
        [
          for (final (c, v) in row.indexed)
            if (c != counter) v,
        ],
    ],
  );

  TallyBoard cleared() => TallyBoard.begin(players, counters);
}
