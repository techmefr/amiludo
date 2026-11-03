enum PhotoError implements Exception { tooLarge, tooMany }

class Highlight {
  const Highlight({required this.id, required this.text, this.at = 0});

  final String id, text;
  final int at;

  Map<String, Object?> toJson() => {'id': id, 'text': text, 'at': at};

  factory Highlight.fromJson(Map<String, dynamic> j) {
    final text = j['text'] as String;
    if (text.trim().isEmpty || text.length > 280) {
      throw const FormatException('Moment fort invalide');
    }
    return Highlight(id: j['id'] as String, text: text, at: j['at'] as int);
  }
}

class GameMemory {
  const GameMemory({
    required this.sessionId,
    this.note = '',
    this.highlights = const [],
    this.photoIds = const [],
  });

  final String sessionId, note;
  final List<Highlight> highlights;
  final List<String> photoIds;

  bool get isEmpty => note.isEmpty && highlights.isEmpty && photoIds.isEmpty;

  GameMemory copyWith({
    String? note,
    List<Highlight>? highlights,
    List<String>? photoIds,
  }) => GameMemory(
    sessionId: sessionId,
    note: note ?? this.note,
    highlights: highlights ?? this.highlights,
    photoIds: photoIds ?? this.photoIds,
  );

  GameMemory merge(GameMemory other) => copyWith(
    note: note.isEmpty ? other.note : note,
    highlights: [
      ...highlights,
      ...other.highlights.where((h) => highlights.every((m) => m.id != h.id)),
    ]..sort((a, b) => a.at.compareTo(b.at)),
    photoIds: {...photoIds, ...other.photoIds}.toList(),
  );

  Map<String, Object?> toJson() => {
    'sessionId': sessionId,
    'note': note,
    'highlights': highlights.map((h) => h.toJson()).toList(),
    'photoIds': photoIds,
  };

  factory GameMemory.fromJson(Map<String, dynamic> j) {
    final note = j['note'] as String? ?? '';
    if (note.length > 4000) throw const FormatException('Note trop longue');
    return GameMemory(
      sessionId: j['sessionId'] as String,
      note: note,
      highlights: (j['highlights'] as List? ?? const [])
          .map((h) => Highlight.fromJson(Map<String, dynamic>.from(h as Map)))
          .toList(),
      photoIds: List<String>.from(j['photoIds'] as List? ?? const []),
    );
  }
}
