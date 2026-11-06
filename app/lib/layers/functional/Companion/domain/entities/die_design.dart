enum DieFaceKind { text, icon, image }

const minDieFaces = 2;
const maxDieFaces = 100;
const solidSides = [4, 6, 8, 10, 12, 20];
const defaultDieColor = 0xFF3D7BD9;
const maxFaceText = 12;
const maxDesignName = 40;

int _dieCounter = 0;

String dieId() =>
    '${DateTime.now().microsecondsSinceEpoch}-${_dieCounter++}';

enum DieShape {
  coin,
  d4,
  d6,
  d8,
  d10,
  d12,
  d20,
  generic;

  static DieShape forSides(int sides) => switch (sides) {
    2 => DieShape.coin,
    4 => DieShape.d4,
    6 => DieShape.d6,
    8 => DieShape.d8,
    10 => DieShape.d10,
    12 => DieShape.d12,
    20 => DieShape.d20,
    _ => DieShape.generic,
  };
}

class DieFaceContent {
  const DieFaceContent({
    this.kind = DieFaceKind.text,
    this.value = '',
    this.color,
  });

  factory DieFaceContent.number(int n) => DieFaceContent(value: '$n');

  factory DieFaceContent.fromJson(Map<String, dynamic> j) {
    final kind = DieFaceKind.values.asNameMap()[j['kind']];
    final value = j['value'];
    final color = j['color'];
    if (kind == null ||
        value is! String ||
        value.length > 80 ||
        (color != null && color is! int)) {
      throw const FormatException('Face invalide');
    }
    return DieFaceContent(kind: kind, value: value, color: color as int?);
  }

  final DieFaceKind kind;
  final String value;
  final int? color;

  String get label => kind == DieFaceKind.text ? value : '';

  DieFaceContent copyWith({DieFaceKind? kind, String? value, int? color}) =>
      DieFaceContent(
        kind: kind ?? this.kind,
        value: value ?? this.value,
        color: color ?? this.color,
      );

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'value': value,
    if (color != null) 'color': color,
  };

  @override
  bool operator ==(Object other) =>
      other is DieFaceContent &&
      other.kind == kind &&
      other.value == value &&
      other.color == color;

  @override
  int get hashCode => Object.hash(kind, value, color);
}

class DieDesign {
  const DieDesign({
    required this.id,
    required this.name,
    required this.faces,
    this.color = defaultDieColor,
  });

  factory DieDesign.standard(String id, String name, int sides) => DieDesign(
    id: id,
    name: name,
    faces: [for (var i = 1; i <= sides; i++) DieFaceContent.number(i)],
  );

  factory DieDesign.fromJson(Map<String, dynamic> j) {
    final id = j['id'], name = j['name'], faces = j['faces'], color = j['color'];
    if (id is! String ||
        id.isEmpty ||
        id.length > 64 ||
        name is! String ||
        name.trim().isEmpty ||
        name.length > maxDesignName ||
        faces is! List ||
        faces.length < minDieFaces ||
        faces.length > maxDieFaces ||
        (color != null && color is! int)) {
      throw const FormatException('Dé invalide');
    }
    return DieDesign(
      id: id,
      name: name,
      color: (color as int?) ?? defaultDieColor,
      faces: [
        for (final f in faces)
          DieFaceContent.fromJson(Map<String, dynamic>.from(f as Map)),
      ],
    );
  }

  final String id, name;
  final int color;
  final List<DieFaceContent> faces;

  int get sides => faces.length;

  DieShape get shape => DieShape.forSides(sides);

  bool get numeric =>
      faces.every((f) => f.kind == DieFaceKind.text && int.tryParse(f.value) != null);

  Set<String> get imageIds => {
    for (final f in faces)
      if (f.kind == DieFaceKind.image) f.value,
  };

  DieDesign copyWith({
    String? id,
    String? name,
    int? color,
    List<DieFaceContent>? faces,
  }) => DieDesign(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
    faces: faces ?? this.faces,
  );

  DieDesign resized(int sides) {
    final next = sides.clamp(minDieFaces, maxDieFaces);
    return copyWith(
      faces: [
        for (var i = 0; i < next; i++)
          i < faces.length ? faces[i] : DieFaceContent.number(i + 1),
      ],
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'faces': faces.map((f) => f.toJson()).toList(),
  };
}
