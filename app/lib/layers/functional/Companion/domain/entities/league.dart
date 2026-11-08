const winPoints = 3;
const drawPoints = 1;

class LeagueMatch {
  const LeagueMatch(this.home, this.away, this.homeScore, this.awayScore);
  final int home, away, homeScore, awayScore;
}

class Standing {
  const Standing({
    required this.player,
    this.played = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.scored = 0,
    this.conceded = 0,
  });
  final int player, played, wins, draws, losses, scored, conceded;

  int get points => wins * winPoints + draws * drawPoints;

  int get difference => scored - conceded;

  Standing record(int goalsFor, int goalsAgainst) => Standing(
    player: player,
    played: played + 1,
    wins: wins + (goalsFor > goalsAgainst ? 1 : 0),
    draws: draws + (goalsFor == goalsAgainst ? 1 : 0),
    losses: losses + (goalsFor < goalsAgainst ? 1 : 0),
    scored: scored + goalsFor,
    conceded: conceded + goalsAgainst,
  );
}

List<Standing> standings(int players, List<LeagueMatch> matches) {
  final table = [for (var i = 0; i < players; i++) Standing(player: i)];
  for (final m in matches) {
    table[m.home] = table[m.home].record(m.homeScore, m.awayScore);
    table[m.away] = table[m.away].record(m.awayScore, m.homeScore);
  }
  return table..sort((a, b) {
    final byPoints = b.points.compareTo(a.points);
    if (byPoints != 0) return byPoints;
    final byDifference = b.difference.compareTo(a.difference);
    return byDifference != 0 ? byDifference : b.scored.compareTo(a.scored);
  });
}
