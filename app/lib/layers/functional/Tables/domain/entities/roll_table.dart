String newTableId() => DateTime.now().microsecondsSinceEpoch.toString();

class RollTable {
  const RollTable({
    required this.id,
    required this.name,
    this.entries = const [],
  });

  factory RollTable.fromJson(Map<String, dynamic> j) => RollTable(
    id: j['id'] as String? ?? newTableId(),
    name: j['name'] as String? ?? '',
    entries: [
      for (final e in j['entries'] as List? ?? const [])
        if (e is String && e.trim().isNotEmpty) e.trim(),
    ],
  );

  factory RollTable.fromText(String id, String name, String text) =>
      RollTable(id: id, name: name, entries: entriesOf(text));

  final String id, name;
  final List<String> entries;

  String get text => entries.join('\n');

  String? roll(int Function(int count) pick) =>
      entries.isEmpty ? null : entries[pick(entries.length)];

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'entries': entries};
}

List<String> entriesOf(String text) => [
  for (final line in text.split('\n'))
    if (line.trim().isNotEmpty) line.trim(),
];

class RollTables {
  const RollTables({this.tables = const []});

  factory RollTables.fromJson(Map<String, dynamic> j) => RollTables(
    tables: [
      for (final t in j['tables'] as List? ?? const [])
        RollTable.fromJson(Map<String, dynamic>.from(t as Map)),
    ],
  );

  final List<RollTable> tables;

  bool get isEmpty => tables.isEmpty;

  RollTable? of(String id) => tables.where((t) => t.id == id).firstOrNull;

  RollTables put(RollTable next) {
    final known = tables.any((t) => t.id == next.id);
    return RollTables(
      tables: known
          ? [for (final t in tables) t.id == next.id ? next : t]
          : [...tables, next],
    );
  }

  RollTables remove(String id) => RollTables(
    tables: [
      for (final t in tables)
        if (t.id != id) t,
    ],
  );

  RollTables addAll(Iterable<RollTable> more) =>
      RollTables(tables: [...tables, ...more]);

  Map<String, Object?> toJson() => {
    'tables': [for (final t in tables) t.toJson()],
  };
}
