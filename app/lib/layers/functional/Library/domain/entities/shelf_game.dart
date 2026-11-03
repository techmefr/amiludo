const gameGenres = [
  'coop',
  'strategy',
  'bluff',
  'party',
  'dice',
  'cards',
  'family',
  'duel',
  'deckbuilding',
  'roleplay',
];

const gameGenreLabels = {
  'coop': ('Coopératif', 'Cooperative'),
  'strategy': ('Stratégie', 'Strategy'),
  'bluff': ('Bluff', 'Bluff'),
  'party': ('Ambiance', 'Party'),
  'dice': ('Dés', 'Dice'),
  'cards': ('Cartes', 'Cards'),
  'family': ('Familial', 'Family'),
  'duel': ('Duel', 'Duel'),
  'deckbuilding': ('Deckbuilding', 'Deckbuilding'),
  'roleplay': ('Jeu de rôle', 'Roleplay'),
};

const shelfColors = [
  0xff6644d6,
  0xffd94f3d,
  0xff2f8f6b,
  0xfff6c445,
  0xff2d6cdf,
  0xff1f2937,
  0xffe07a2e,
  0xff9b4dca,
];

class ShelfGame {
  const ShelfGame({
    required this.id,
    required this.name,
    this.genres = const [],
    this.minPlayers = 2,
    this.maxPlayers = 4,
    this.minutes = 45,
    this.color = 0xff6644d6,
    this.templateIds = const [],
    this.addedAt = 0,
  });

  final String id, name;
  final List<String> genres, templateIds;
  final int minPlayers, maxPlayers, minutes, color, addedAt;

  bool fits(int players) => players >= minPlayers && players <= maxPlayers;

  ShelfGame copyWith({
    String? name,
    List<String>? genres,
    int? minPlayers,
    int? maxPlayers,
    int? minutes,
    int? color,
    List<String>? templateIds,
  }) => ShelfGame(
    id: id,
    name: name ?? this.name,
    genres: genres ?? this.genres,
    minPlayers: minPlayers ?? this.minPlayers,
    maxPlayers: maxPlayers ?? this.maxPlayers,
    minutes: minutes ?? this.minutes,
    color: color ?? this.color,
    templateIds: templateIds ?? this.templateIds,
    addedAt: addedAt,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'genres': genres,
    'minPlayers': minPlayers,
    'maxPlayers': maxPlayers,
    'minutes': minutes,
    'color': color,
    'templateIds': templateIds,
    'addedAt': addedAt,
  };

  factory ShelfGame.fromJson(Map<String, dynamic> j) {
    final name = (j['name'] as String).trim();
    final minPlayers = j['minPlayers'] as int? ?? 2;
    final maxPlayers = j['maxPlayers'] as int? ?? 4;
    if (name.isEmpty || name.length > 80) {
      throw const FormatException('Nom de jeu invalide');
    }
    if (minPlayers < 1 || maxPlayers < minPlayers || maxPlayers > 100) {
      throw const FormatException('Nombre de joueurs invalide');
    }
    return ShelfGame(
      id: j['id'] as String,
      name: name,
      genres: List<String>.from(j['genres'] as List? ?? const [])
          .where(gameGenres.contains)
          .toList(),
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
      minutes: (j['minutes'] as int? ?? 45).clamp(1, 6000),
      color: j['color'] as int? ?? 0xff6644d6,
      templateIds: List<String>.from(j['templateIds'] as List? ?? const []),
      addedAt: j['addedAt'] as int? ?? 0,
    );
  }
}
