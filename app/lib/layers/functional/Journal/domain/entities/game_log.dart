class LogEntry {
  const LogEntry({required this.id, required this.text, required this.at});

  factory LogEntry.fromJson(Map<String, dynamic> j) => LogEntry(
    id: j['id'] as String? ?? '',
    text: j['text'] as String? ?? '',
    at: DateTime.fromMillisecondsSinceEpoch(
      j['at'] as int? ?? 0,
      isUtc: true,
    ),
  );

  final String id, text;
  final DateTime at;

  Map<String, Object?> toJson() => {
    'id': id,
    'text': text,
    'at': at.millisecondsSinceEpoch,
  };
}

class GameLog {
  const GameLog({this.entries = const []});

  factory GameLog.fromJson(Map<String, dynamic> j) => GameLog(
    entries: [
      for (final e in j['journal'] as List? ?? const [])
        LogEntry.fromJson(Map<String, dynamic>.from(e as Map)),
    ],
  );

  final List<LogEntry> entries;

  bool get isEmpty => entries.isEmpty;

  GameLog add(String text, DateTime at) {
    final clean = text.trim();
    if (clean.isEmpty) return this;
    final entry = LogEntry(
      id: '${at.microsecondsSinceEpoch}-${entries.length}',
      text: clean,
      at: at.toUtc(),
    );
    return GameLog(entries: [entry, ...entries]);
  }

  GameLog remove(String id) =>
      GameLog(entries: [for (final e in entries) if (e.id != id) e]);

  Map<String, Object?> toJson() => {
    'journal': [for (final e in entries) e.toJson()],
  };
}
