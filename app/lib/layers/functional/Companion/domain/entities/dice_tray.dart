import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_library.dart';
import 'package:amiludo/layers/technical/Physics/seeded_random.dart';

const diceTrayBrickType = 'dice-tray';
const standardSides = [4, 6, 8, 10, 12, 20];
const maxTrayDice = 12;
const maxCustomFaces = 100;
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
    this.design,
  });

  factory DiceSpec.fromDesign(DieDesign design) => DiceSpec(
    sides: design.sides,
    faces: [
      for (final f in design.faces) f.label.isEmpty ? f.kind.name : f.label,
    ],
    color: design.color,
    design: design,
  );

  factory DiceSpec.fromJson(Map<String, dynamic> j) {
    final raw = j['design'];
    if (raw is Map) {
      try {
        return DiceSpec.fromDesign(
          DieDesign.fromJson(Map<String, dynamic>.from(raw)),
        );
      } on FormatException {
        return DiceSpec(sides: ((j['sides'] as num?)?.toInt() ?? 6));
      }
    }
    final faces = [for (final f in j['faces'] as List? ?? const []) '$f'];
    return DiceSpec(
      sides: faces.isEmpty
          ? ((j['sides'] as num?)?.toInt() ?? 6)
          : faces.length,
      faces: faces,
      color: (j['color'] as num? ?? 0xFF3D7BD9).toInt(),
    );
  }

  factory DiceSpec.custom(List<String> faces, int color) =>
      DiceSpec(sides: faces.length, faces: faces, color: color);

  final int sides, color;
  final List<String> faces;
  final DieDesign? design;

  bool get custom => faces.isNotEmpty;

  String faceLabel(int value) => custom ? faces[value - 1] : '$value';

  DieFaceContent faceContent(int value) =>
      design?.faces[value - 1] ?? DieFaceContent(value: faceLabel(value));

  int? scoreOf(int value) {
    final d = design;
    if (d != null) {
      return d.numeric ? int.parse(d.faces[value - 1].value) : null;
    }
    return custom ? null : value;
  }

  String get name => design?.name ?? (custom ? faces.join(' ') : 'd$sides');

  Map<String, dynamic> toJson() => {
    'sides': sides,
    if (custom) 'faces': faces,
    'color': color,
    if (design != null) 'design': design!.toJson(),
  };
}

class DiceTraySettings {
  const DiceTraySettings({
    this.dice = const [DiceSpec(sides: 6), DiceSpec(sides: 6)],
    this.surface = 'wood',
    this.resultMode = 'sum',
  });

  factory DiceTraySettings.fromJson(Map<String, dynamic> j) {
    final parsed = [
      for (final d in j['dice'] as List? ?? const [])
        DiceSpec.fromJson(Map<String, dynamic>.from(d as Map)),
    ].where((d) => d.sides >= 2).take(maxTrayDice).toList();
    final surface = '${j['surface'] ?? 'wood'}';
    return DiceTraySettings(
      dice: parsed.isEmpty ? const DiceTraySettings().dice : parsed,
      surface: surface,
      resultMode: '${j['result'] ?? 'sum'}',
    );
  }

  final List<DiceSpec> dice;
  final String surface, resultMode;

  DiceTraySettings resolved(DieLibrary library) => DiceTraySettings(
    dice: [
      for (final d in dice)
        d.design == null
            ? d
            : DiceSpec.fromDesign(library.byId(d.design!.id) ?? d.design!),
    ],
    surface: surface,
    resultMode: resultMode,
  );

  DiceTraySettings withSurface(String next) =>
      DiceTraySettings(dice: dice, surface: next, resultMode: resultMode);

  DiceTraySettings withResultMode(String next) =>
      DiceTraySettings(dice: dice, surface: surface, resultMode: next);

  Map<String, dynamic> toJson() => {
    'dice': dice.map((d) => d.toJson()).toList(),
    'surface': surface,
    if (resultMode != 'sum') 'result': resultMode,
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
      sum += settings.dice[i].scoreOf(list[i]) ?? 0;
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

  DiceTraySession withMode(String mode) => DiceTraySession(
    settings: settings.withResultMode(mode),
    values: values,
    kept: kept,
    history: history,
  );

  DiceTraySession cleared() =>
      DiceTraySession(settings: settings, history: history);

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
