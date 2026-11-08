String newSceneId() => DateTime.now().microsecondsSinceEpoch.toString();

List<String> _strings(Object? value) => [
  for (final v in value as List? ?? const [])
    if (v is String) v,
];

class Scene {
  const Scene({
    required this.id,
    required this.title,
    this.notes = '',
    this.handout = '',
    this.nextIds = const [],
    this.creatureIds = const [],
    this.ambience,
  });

  factory Scene.fromJson(Map<String, dynamic> j) => Scene(
    id: j['id'] as String? ?? newSceneId(),
    title: j['title'] as String? ?? '',
    notes: j['notes'] as String? ?? '',
    handout: j['handout'] as String? ?? '',
    nextIds: _strings(j['nextIds']),
    creatureIds: _strings(j['creatureIds']),
    ambience: j['ambience'] as String?,
  );

  final String id, title, notes, handout;
  final List<String> nextIds, creatureIds;
  final String? ambience;

  Scene copyWith({List<String>? nextIds, List<String>? creatureIds}) => Scene(
    id: id,
    title: title,
    notes: notes,
    handout: handout,
    nextIds: nextIds ?? this.nextIds,
    creatureIds: creatureIds ?? this.creatureIds,
    ambience: ambience,
  );

  bool get hasHandout => handout.trim().isNotEmpty;

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'notes': notes,
    'handout': handout,
    'nextIds': nextIds,
    'creatureIds': creatureIds,
    'ambience': ambience,
  };
}
