const minLevel = 1;
const maxLevel = 5;

List<List<int>> balanceTeams(List<int> levels, {int teams = 2}) {
  final order = [for (var i = 0; i < levels.length; i++) i]
    ..sort((a, b) => levels[b].compareTo(levels[a]));
  final groups = [for (var t = 0; t < teams; t++) <int>[]];
  final totals = List<int>.filled(teams, 0);
  for (final player in order) {
    var best = 0;
    for (var t = 1; t < teams; t++) {
      if (totals[t] < totals[best] ||
          (totals[t] == totals[best] &&
              groups[t].length < groups[best].length)) {
        best = t;
      }
    }
    groups[best].add(player);
    totals[best] += levels[player];
  }
  return groups;
}
