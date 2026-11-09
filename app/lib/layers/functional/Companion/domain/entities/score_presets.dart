class SheetRow {
  const SheetRow(this.id, {this.unit = 1});
  final String id;
  final int unit;
}

class ScorePreset {
  const ScorePreset(
    this.id,
    this.rows, {
    this.lowestWins = false,
    this.bonusRows = 0,
    this.bonusThreshold = 0,
    this.bonusPoints = 0,
    this.rounds = false,
  });
  final String id;
  final List<SheetRow> rows;
  final bool lowestWins, rounds;
  final int bonusRows, bonusThreshold, bonusPoints;

  bool get hasBonus => bonusRows > 0;
}

const scorePresets = [
  ScorePreset(
    'yams',
    [
      SheetRow('ones'),
      SheetRow('twos'),
      SheetRow('threes'),
      SheetRow('fours'),
      SheetRow('fives'),
      SheetRow('sixes'),
      SheetRow('three-kind'),
      SheetRow('four-kind'),
      SheetRow('full-house'),
      SheetRow('small-straight'),
      SheetRow('large-straight'),
      SheetRow('yams'),
      SheetRow('chance'),
    ],
    bonusRows: 6,
    bonusThreshold: 63,
    bonusPoints: 35,
  ),
  ScorePreset('catan', [
    SheetRow('settlements'),
    SheetRow('cities', unit: 2),
    SheetRow('longest-road', unit: 2),
    SheetRow('largest-army', unit: 2),
    SheetRow('victory-cards'),
  ]),
  ScorePreset('skyjo', [], lowestWins: true, rounds: true),
];

ScorePreset presetById(String id) =>
    scorePresets.firstWhere((p) => p.id == id, orElse: () => scorePresets.first);

int sheetBonus(ScorePreset preset, List<int> values) {
  if (!preset.hasBonus) return 0;
  final upper = values
      .take(preset.bonusRows)
      .fold<int>(0, (sum, value) => sum + value);
  return upper >= preset.bonusThreshold ? preset.bonusPoints : 0;
}

int sheetTotal(ScorePreset preset, List<int> values) {
  var total = 0;
  for (final (i, value) in values.indexed) {
    final unit = i < preset.rows.length ? preset.rows[i].unit : 1;
    total += value * unit;
  }
  return total + sheetBonus(preset, values);
}
