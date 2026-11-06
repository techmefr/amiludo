enum CounterDisplay { number, bar, hearts, pips }

enum CounterOutcome { none, eliminated, skipTurn }

class CounterSettings {
  const CounterSettings({
    this.name = '',
    this.icon = 'star',
    this.start = 0,
    this.minimum,
    this.maximum,
    this.step = 1,
    this.color = 0xFF3D7BD9,
    this.display = CounterDisplay.number,
    this.outcome = CounterOutcome.none,
  });

  factory CounterSettings.fromJson(Map<String, dynamic> j) => CounterSettings(
    name: j['name'] as String? ?? '',
    icon: j['icon'] as String? ?? 'star',
    start: (j['start'] as num? ?? 0).toDouble(),
    minimum: (j['minimum'] as num?)?.toDouble(),
    maximum: (j['maximum'] as num?)?.toDouble(),
    step: (j['step'] as num? ?? 1).toDouble(),
    color: (j['color'] as num? ?? 0xFF3D7BD9).toInt(),
    display: CounterDisplay.values.firstWhere(
      (d) => d.name == j['display'],
      orElse: () => CounterDisplay.number,
    ),
    outcome: CounterOutcome.values.firstWhere(
      (o) => o.name == j['outcome'],
      orElse: () => CounterOutcome.none,
    ),
  );

  final String name, icon;
  final double start, step;
  final double? minimum, maximum;
  final int color;
  final CounterDisplay display;
  final CounterOutcome outcome;

  double clamp(double value) {
    final low = minimum, high = maximum;
    if (low != null && value < low) return low;
    if (high != null && value > high) return high;
    return value;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'icon': icon,
    'start': start,
    if (minimum != null) 'minimum': minimum,
    if (maximum != null) 'maximum': maximum,
    'step': step,
    'color': color,
    'display': display.name,
    'outcome': outcome.name,
  };
}

class CounterState {
  CounterState(this.settings, {double? value})
    : value = settings.clamp(value ?? settings.start);

  final CounterSettings settings;
  double value;
  final List<double> history = [];

  bool get atMinimum => settings.minimum != null && value <= settings.minimum!;

  bool get triggersOutcome =>
      atMinimum && settings.outcome != CounterOutcome.none;

  void change(double delta) {
    final next = settings.clamp(value + delta);
    if (next == value) return;
    history.add(value);
    value = next;
  }

  void increase() => change(settings.step);

  void decrease() => change(-settings.step);

  void reset() {
    if (value == settings.start) return;
    history.add(value);
    value = settings.clamp(settings.start);
  }

  bool get canUndo => history.isNotEmpty;

  void undo() {
    if (history.isEmpty) return;
    value = history.removeLast();
  }
}

const lifePreset = CounterSettings(
  name: 'life',
  icon: 'heart',
  start: 50,
  minimum: 0,
  maximum: 99,
  color: 0xFFD94A4A,
  display: CounterDisplay.bar,
  outcome: CounterOutcome.eliminated,
);

const pointsPreset = CounterSettings(name: 'points', icon: 'star');

const chipsPreset = CounterSettings(
  name: 'chips',
  icon: 'coin',
  start: 1000,
  minimum: 0,
  step: 50,
  color: 0xFFE0A526,
);

const potPreset = CounterSettings(
  name: 'pot',
  icon: 'coin',
  minimum: 0,
  step: 50,
  color: 0xFFE0A526,
);
