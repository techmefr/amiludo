class RankedPlayer {
  const RankedPlayer(this.name, this.score, this.rank, {this.tied = false});
  final String name;
  final num score;
  final int rank;
  final bool tied;
}

List<RankedPlayer> rankPlayers(
  List<String> names,
  List<num?> scores, {
  bool lowestWins = false,
}) {
  final entered = [
    for (final (i, name) in names.indexed)
      if (scores[i] != null) (name, scores[i]!),
  ];
  entered.sort(
    (a, b) => lowestWins ? a.$2.compareTo(b.$2) : b.$2.compareTo(a.$2),
  );
  final ranked = <RankedPlayer>[];
  for (final (i, (name, score)) in entered.indexed) {
    final rank = i > 0 && entered[i - 1].$2 == score
        ? ranked[i - 1].rank
        : i + 1;
    ranked.add(RankedPlayer(name, score, rank));
  }
  return [
    for (final p in ranked)
      RankedPlayer(
        p.name,
        p.score,
        p.rank,
        tied: ranked.where((o) => o.rank == p.rank).length > 1,
      ),
  ];
}

List<RankedPlayer> winners(List<RankedPlayer> ranking) => [
  for (final p in ranking)
    if (p.rank == 1) p,
];
