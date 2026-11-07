import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';

enum JournalKind { note, dice, oracle, generator, scene }

class JournalLine {
  const JournalLine({
    required this.id,
    required this.at,
    required this.kind,
    required this.text,
  });

  factory JournalLine.create(JournalKind kind, String text, DateTime at) =>
      JournalLine(id: notebookId(), at: at, kind: kind, text: text);

  factory JournalLine.fromJson(Map<String, dynamic> j) => JournalLine(
    id: j['id'] as String,
    at: DateTime.fromMillisecondsSinceEpoch(j['at'] as int? ?? 0),
    kind: JournalKind.values.firstWhere(
      (k) => k.name == j['kind'],
      orElse: () => JournalKind.note,
    ),
    text: j['text'] as String? ?? '',
  );

  final String id, text;
  final DateTime at;
  final JournalKind kind;

  Map<String, Object?> toJson() => {
    'id': id,
    'at': at.millisecondsSinceEpoch,
    'kind': kind.name,
    'text': text,
  };
}

class JournalSession {
  const JournalSession({
    required this.id,
    required this.title,
    required this.startedAt,
    this.endedAt,
    this.lines = const [],
  });

  factory JournalSession.start(String title, DateTime at) =>
      JournalSession(id: notebookId(), title: title, startedAt: at);

  factory JournalSession.fromJson(Map<String, dynamic> j) => JournalSession(
    id: j['id'] as String,
    title: j['title'] as String? ?? '',
    startedAt: DateTime.fromMillisecondsSinceEpoch(j['startedAt'] as int? ?? 0),
    endedAt: j['endedAt'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(j['endedAt'] as int),
    lines: [
      for (final l in j['lines'] as List? ?? const [])
        JournalLine.fromJson(Map<String, dynamic>.from(l as Map)),
    ],
  );

  final String id, title;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<JournalLine> lines;

  bool get active => endedAt == null;

  JournalSession _with({DateTime? end, List<JournalLine>? lines}) =>
      JournalSession(
        id: id,
        title: title,
        startedAt: startedAt,
        endedAt: end ?? endedAt,
        lines: lines ?? this.lines,
      );

  JournalSession withLine(JournalLine line) => _with(lines: [...lines, line]);

  JournalSession withoutLine(String lineId) => _with(
    lines: [
      for (final l in lines)
        if (l.id != lineId) l,
    ],
  );

  JournalSession ended(DateTime at) => _with(end: at);

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'startedAt': startedAt.millisecondsSinceEpoch,
    'endedAt': endedAt?.millisecondsSinceEpoch,
    'lines': [for (final l in lines) l.toJson()],
  };
}
