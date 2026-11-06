class ChroniclesAppearance {
  const ChroniclesAppearance({
    this.skin,
    this.eyes,
    this.eyes2,
    this.hair,
    this.build,
  });
  final String? skin, eyes, eyes2, hair, build;

  factory ChroniclesAppearance.fromJson(Map<String, dynamic> j) =>
      ChroniclesAppearance(
        skin: j['peau'] as String?,
        eyes: j['yeux'] as String?,
        eyes2: j['yeux2'] as String?,
        hair: j['cheveux'] as String?,
        build: j['carrure'] as String?,
      );
}

class ChroniclesCard {
  const ChroniclesCard({
    required this.id,
    required this.universe,
    required this.step,
    required this.type,
    required this.rarity,
    required this.name,
    required this.text,
    this.label,
    this.modifiers = const {},
    this.tags = const [],
    this.conflicts = const [],
    this.appearance,
    this.epithet,
  });

  final String id, universe, type, rarity, name, text;
  final String? label, epithet;
  final int step;
  final Map<String, int> modifiers;
  final List<String> tags, conflicts;
  final ChroniclesAppearance? appearance;

  factory ChroniclesCard.fromJson(Map<String, dynamic> j) {
    List<String> strings(Object? v) =>
        (v as List? ?? const []).map((e) => e as String).toList();
    final appearance = j['apparence'];
    return ChroniclesCard(
      id: j['id'] as String,
      universe: j['univers'] as String,
      step: j['etape'] as int,
      type: j['type'] as String,
      label: j['libelle'] as String?,
      rarity: j['rarete'] as String,
      name: j['nom'] as String,
      text: j['texte'] as String,
      modifiers: (j['modificateurs'] as Map? ?? const {}).map(
        (k, v) => MapEntry(k as String, v as int),
      ),
      tags: strings(j['tags']),
      conflicts: strings(j['conflits']),
      appearance: appearance is Map
          ? ChroniclesAppearance.fromJson(Map<String, dynamic>.from(appearance))
          : null,
      epithet: j['epithete'] as String?,
    );
  }

  bool favors(List<String> stats) =>
      stats.any((s) => (modifiers[s] ?? 0) > 0);

  bool conflictsWith(ChroniclesCard other) =>
      conflicts.any(other.tags.contains) || other.conflicts.any(tags.contains);

  Map<String, Object?> toJson() => {
    'id': id,
    'univers': universe,
    'etape': step,
    'type': type,
    'libelle': label,
    'rarete': rarity,
    'nom': name,
    'texte': text,
    'modificateurs': modifiers,
    'tags': tags,
    'conflits': conflicts,
    'apparence': appearance == null
        ? null
        : {
            'peau': appearance!.skin,
            'yeux': appearance!.eyes,
            'yeux2': appearance!.eyes2,
            'cheveux': appearance!.hair,
            'carrure': appearance!.build,
          },
    'epithete': epithet,
  };
}
