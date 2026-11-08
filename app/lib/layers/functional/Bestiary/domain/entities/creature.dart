import 'package:amiludo/layers/functional/Rules/domain/entities/rule_book.dart';

enum CreatureKind { npc, monster, treasure }

String newCreatureId() => DateTime.now().microsecondsSinceEpoch.toString();

class CreatureField {
  const CreatureField(this.label, this.value);

  factory CreatureField.fromJson(Map<String, dynamic> j) => CreatureField(
    j['label'] as String? ?? '',
    j['value'] as String? ?? '',
  );

  final String label, value;

  Map<String, Object?> toJson() => {'label': label, 'value': value};
}

class Creature {
  const Creature({
    required this.id,
    required this.name,
    this.kind = CreatureKind.monster,
    this.tags = const [],
    this.fields = const [],
    this.notes = '',
  });

  factory Creature.fromJson(Map<String, dynamic> j) => Creature(
    id: j['id'] as String? ?? newCreatureId(),
    name: j['name'] as String? ?? '',
    kind: CreatureKind.values.firstWhere(
      (k) => k.name == j['kind'],
      orElse: () => CreatureKind.monster,
    ),
    tags: [
      for (final t in j['tags'] as List? ?? const [])
        if (t is String && t.trim().isNotEmpty) t.trim(),
    ],
    fields: [
      for (final f in j['fields'] as List? ?? const [])
        CreatureField.fromJson(Map<String, dynamic>.from(f as Map)),
    ],
    notes: j['notes'] as String? ?? '',
  );

  final String id, name, notes;
  final CreatureKind kind;
  final List<String> tags;
  final List<CreatureField> fields;

  bool matches(String query) {
    final needle = foldText(query.trim());
    if (needle.isEmpty) return true;
    return [
      name,
      notes,
      ...tags,
      for (final f in fields) ...[f.label, f.value],
    ].any((text) => foldText(text).contains(needle));
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'kind': kind.name,
    'tags': tags,
    'fields': [for (final f in fields) f.toJson()],
    'notes': notes,
  };
}
