import 'dart:math';

enum EntryKind { npc, place, quest, loot, faction }

enum SectionType { description, notes, checklist, tags, stats, pictures }

final _random = Random();

String notebookId() =>
    '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'
    '${_random.nextInt(1 << 20).toRadixString(36)}';

T _named<T extends Enum>(List<T> values, Object? name, T fallback) =>
    values.firstWhere((v) => v.name == name, orElse: () => fallback);

class CheckItem {
  const CheckItem({required this.text, this.done = false});

  factory CheckItem.fromJson(Map<String, dynamic> j) =>
      CheckItem(text: j['text'] as String? ?? '', done: j['done'] == true);

  final String text;
  final bool done;

  CheckItem toggled() => CheckItem(text: text, done: !done);

  Map<String, Object?> toJson() => {'text': text, 'done': done};
}

class StatLine {
  const StatLine({required this.name, required this.value});

  factory StatLine.fromJson(Map<String, dynamic> j) => StatLine(
    name: j['name'] as String? ?? '',
    value: j['value'] as String? ?? '',
  );

  final String name, value;

  Map<String, Object?> toJson() => {'name': name, 'value': value};
}

class EntrySection {
  const EntrySection({
    required this.id,
    required this.type,
    this.title = '',
    this.text = '',
    this.items = const [],
    this.tags = const [],
    this.stats = const [],
    this.pictures = const [],
  });

  factory EntrySection.fromJson(Map<String, dynamic> j) => EntrySection(
    id: j['id'] as String,
    type: _named(SectionType.values, j['type'], SectionType.notes),
    title: j['title'] as String? ?? '',
    text: j['text'] as String? ?? '',
    items: [
      for (final i in j['items'] as List? ?? const [])
        CheckItem.fromJson(Map<String, dynamic>.from(i as Map)),
    ],
    tags: List<String>.from(j['tags'] as List? ?? const []),
    stats: [
      for (final s in j['stats'] as List? ?? const [])
        StatLine.fromJson(Map<String, dynamic>.from(s as Map)),
    ],
    pictures: List<String>.from(j['pictures'] as List? ?? const []),
  );

  final String id, title, text;
  final SectionType type;
  final List<CheckItem> items;
  final List<String> tags;
  final List<StatLine> stats;
  final List<String> pictures;

  EntrySection copyWith({
    String? title,
    String? text,
    List<CheckItem>? items,
    List<String>? tags,
    List<StatLine>? stats,
    List<String>? pictures,
  }) => EntrySection(
    id: id,
    type: type,
    title: title ?? this.title,
    text: text ?? this.text,
    items: items ?? this.items,
    tags: tags ?? this.tags,
    stats: stats ?? this.stats,
    pictures: pictures ?? this.pictures,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'text': text,
    'items': [for (final i in items) i.toJson()],
    'tags': tags,
    'stats': [for (final s in stats) s.toJson()],
    'pictures': pictures,
  };
}

class NotebookEntry {
  const NotebookEntry({
    required this.id,
    required this.kind,
    required this.name,
    this.parentId,
    this.mapKey,
    this.sections = const [],
  });

  factory NotebookEntry.create(
    EntryKind kind,
    String name, {
    String? parentId,
  }) {
    final types = [
      SectionType.description,
      if (kind == EntryKind.quest) SectionType.checklist,
      if (kind == EntryKind.npc || kind == EntryKind.loot) SectionType.stats,
      SectionType.notes,
    ];
    return NotebookEntry(
      id: notebookId(),
      kind: kind,
      name: name,
      parentId: parentId,
      sections: [
        for (final t in types) EntrySection(id: notebookId(), type: t),
      ],
    );
  }

  factory NotebookEntry.fromJson(Map<String, dynamic> j) => NotebookEntry(
    id: j['id'] as String,
    kind: _named(EntryKind.values, j['kind'], EntryKind.npc),
    name: j['name'] as String? ?? '',
    parentId: j['parentId'] as String?,
    mapKey: j['mapKey'] as String?,
    sections: [
      for (final s in j['sections'] as List? ?? const [])
        EntrySection.fromJson(Map<String, dynamic>.from(s as Map)),
    ],
  );

  final String id, name;
  final EntryKind kind;
  final String? parentId, mapKey;
  final List<EntrySection> sections;

  Iterable<String> get texts => [
    for (final s in sections) ...[
      s.text,
      ...s.tags,
      for (final i in s.items) i.text,
    ],
  ];

  Set<String> get pictureIds => {for (final s in sections) ...s.pictures};

  NotebookEntry copyWith({
    String? name,
    String? parentId,
    String? mapKey,
    List<EntrySection>? sections,
  }) => NotebookEntry(
    id: id,
    kind: kind,
    name: name ?? this.name,
    parentId: parentId ?? this.parentId,
    mapKey: mapKey ?? this.mapKey,
    sections: sections ?? this.sections,
  );

  NotebookEntry withoutParent() => NotebookEntry(
    id: id,
    kind: kind,
    name: name,
    mapKey: mapKey,
    sections: sections,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind.name,
    'name': name,
    'parentId': parentId,
    'mapKey': mapKey,
    'sections': [for (final s in sections) s.toJson()],
  };
}
