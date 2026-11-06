import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/technical/Physics/seeded_random.dart';

const diceTrayBrickType = 'dice-tray';
const standardSides = [4, 6, 8, 10, 12, 20];
const maxTrayDice = 12;
const maxCustomFaces = 12;
const facePalette = [
  0xFF3D7BD9,
  0xFFD9573D,
  0xFF3DA66B,
  0xFFD9A63D,
  0xFF8A65D8,
  0xFFCB78A8,
];

class DiceSpec {
  const DiceSpec({
    required this.sides,
    this.faces = const [],
    this.color = 0xFF3D7BD9,
  });

  factory DiceSpec.fromJson(Map<String, dynamic> j) {
    final faces = [for (final f in j['faces'] as List? ?? const []) '$f'];
    return DiceSpec(
      sides: faces.isEmpty ? ((j['sides'] as num?)?.toInt() ?? 6) : faces.length,
      faces: faces,
      color: (j['color'] as num? ?? 0xFF3D7BD9).toInt(),
    );
  }

  factory DiceSpec.custom(List<String> faces, int color) =>
      DiceSpec(sides: faces.length, faces: faces, color: color);

  final int sides, color;
  final List<String> faces;

  bool get custom => faces.isNotEmpty;

  String faceLabel(int value) => custom ? faces[value - 1] : '$value';

  String get name => custom ? faces.join(' ') : 'd$sides';

  Map<String, dynamic> toJson() => {
    'sides': sides,
    if (custom) 'faces': faces,
    'color': color,
  };
}

class DiceTraySettings {
  const DiceTraySettings({
    this.dice = const [DiceSpec(sides: 6), DiceSpec(sides: 6)],
    this.surface = 'wood',
  });

  factory DiceTraySettings.fromJson(Map<String, dynamic> j) {
    final parsed = [
      for (final d in j['dice'] as List? ?? const [])
        DiceSpec.fromJson(Map<String, dynamic>.from(d as Map)),
    ].where((d) => d.sides >= 2).take(maxTrayDice).toList();
    final surface = '${j['surface'] ?? 'wood'}';
    return parsed.isEmpty
        ? DiceTraySettings(surface: surface)
        : DiceTraySettings(dice: parsed, surface: surface);
  }

  final List<DiceSpec> dice;
  final String surface;

  DiceTraySettings withSurface(String next) =>
      DiceTraySettings(dice: dice, surface: next);

  Map<String, dynamic> toJson() => {
    'dice': dice.map((d) => d.toJson()).toList(),
    'surface': surface,
  };

  Brick toBrick(String id) =>
      Brick(id: id, type: diceTrayBrickType, settings: toJson());
}

class TrayRoll {
  const TrayRoll(this.values, this.total);
  final List<int> values;
  final int total;
}

class DiceTraySession {
  const DiceTraySession({
    required this.settings,
    this.values = const [],
    this.kept = const {},
    this.history = const [],
  });

  final DiceTraySettings settings;
  final List<int> values;
  final Set<int> kept;
  final List<TrayRoll> history;

  bool get thrown => values.isNotEmpty;

  int get total => totalOf(values);

  int totalOf(List<int> list) {
    var sum = 0;
    for (var i = 0; i < list.length && i < settings.dice.length; i++) {
      if (!settings.dice[i].custom) sum += list[i];
    }
    return sum;
  }

  DiceTraySession withSettings(DiceTraySettings next) =>
      DiceTraySession(settings: next, history: history);

  DiceTraySession throwDice(SeededRandom rng) {
    final next = [
      for (var i = 0; i < settings.dice.length; i++)
        thrown && kept.contains(i)
            ? values[i]
            : rng.nextInt(settings.dice[i].sides) + 1,
    ];
    return DiceTraySession(
      settings: settings,
      values: next,
      kept: kept,
      history: [TrayRoll(next, totalOf(next)), ...history].take(20).toList(),
    );
  }

  DiceTraySession withOutcome(List<int> outcome) {
    if (!thrown || outcome.length != values.length) return this;
    final next = [
      for (var i = 0; i < outcome.length; i++)
        kept.contains(i) ? values[i] : outcome[i],
    ];
    return DiceTraySession(
      settings: settings,
      values: next,
      kept: kept,
      history: [TrayRoll(next, totalOf(next)), ...history.skip(1)],
    );
  }

  DiceTraySession toggleKeep(int index) {
    if (!thrown || index < 0 || index >= values.length) return this;
    final next = {...kept};
    if (!next.add(index)) next.remove(index);
    return DiceTraySession(
      settings: settings,
      values: values,
      kept: next,
      history: history,
    );
  }
}
