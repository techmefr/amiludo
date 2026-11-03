class Friend {
  const Friend({
    required this.id,
    required this.name,
    this.color = 0xfff6c445,
    this.likedGenres = const [],
    this.avoidedGenres = const [],
    this.maxMinutes = 0,
    this.refusedGameIds = const [],
  });

  final String id, name;
  final int color, maxMinutes;
  final List<String> likedGenres, avoidedGenres, refusedGameIds;

  Friend copyWith({
    String? name,
    int? color,
    List<String>? likedGenres,
    List<String>? avoidedGenres,
    int? maxMinutes,
    List<String>? refusedGameIds,
  }) => Friend(
    id: id,
    name: name ?? this.name,
    color: color ?? this.color,
    likedGenres: likedGenres ?? this.likedGenres,
    avoidedGenres: avoidedGenres ?? this.avoidedGenres,
    maxMinutes: maxMinutes ?? this.maxMinutes,
    refusedGameIds: refusedGameIds ?? this.refusedGameIds,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'likedGenres': likedGenres,
    'avoidedGenres': avoidedGenres,
    'maxMinutes': maxMinutes,
    'refusedGameIds': refusedGameIds,
  };

  factory Friend.fromJson(Map<String, dynamic> j) {
    final name = (j['name'] as String).trim();
    if (name.isEmpty || name.length > 40) {
      throw const FormatException('Prénom invalide');
    }
    return Friend(
      id: j['id'] as String,
      name: name,
      color: j['color'] as int? ?? 0xfff6c445,
      likedGenres: List<String>.from(j['likedGenres'] as List? ?? const []),
      avoidedGenres: List<String>.from(j['avoidedGenres'] as List? ?? const []),
      maxMinutes: (j['maxMinutes'] as int? ?? 0).clamp(0, 6000),
      refusedGameIds: List<String>.from(
        j['refusedGameIds'] as List? ?? const [],
      ),
    );
  }
}
