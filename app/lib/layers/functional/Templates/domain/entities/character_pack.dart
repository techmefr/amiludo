class CharacterCard {
  const CharacterCard({required this.name, this.description = ''});
  final String name, description;
  Map<String, Object?> toJson() => {'name': name, 'description': description};
  factory CharacterCard.fromJson(Map<String, dynamic> j) {
    final c = CharacterCard(
      name: j['name'] as String,
      description: j['description'] as String? ?? '',
    );
    if (c.name.trim().isEmpty ||
        c.name.length > 80 ||
        c.description.length > 2000) {
      throw const FormatException('Carte de personnage invalide');
    }
    return c;
  }
}

class CreationCategory {
  const CreationCategory({
    required this.name,
    required this.cards,
    this.draw = 3,
    this.keepMin = 1,
    this.keepMax = 1,
  });
  final String name;
  final List<CharacterCard> cards;
  final int draw, keepMin, keepMax;
  Map<String, Object?> toJson() => {
    'name': name,
    'cards': cards.map((c) => c.toJson()).toList(),
    'draw': draw,
    'keepMin': keepMin,
    'keepMax': keepMax,
  };
  factory CreationCategory.fromJson(Map<String, dynamic> j) {
    final c = CreationCategory(
      name: j['name'] as String,
      cards: (j['cards'] as List)
          .map(
            (v) => CharacterCard.fromJson(Map<String, dynamic>.from(v as Map)),
          )
          .toList(),
      draw: j['draw'] as int,
      keepMin: j['keepMin'] as int,
      keepMax: j['keepMax'] as int,
    );
    if (c.name.trim().isEmpty ||
        c.name.length > 80 ||
        c.cards.isEmpty ||
        c.cards.length > 100 ||
        c.cards.map((c) => c.name).toSet().length != c.cards.length ||
        c.draw < 1 ||
        c.draw > c.cards.length ||
        c.keepMin < 0 ||
        c.keepMax < c.keepMin ||
        c.keepMax < 1 ||
        c.keepMax > c.draw) {
      throw const FormatException(
        'Catégorie de personnage invalide : vérifiez le nombre de cartes tirées et conservées',
      );
    }
    return c;
  }
}

class GameCharacter {
  const GameCharacter({
    required this.id,
    required this.name,
    required this.packName,
    required this.createdAt,
    required this.choices,
  });
  final String id, name, packName;
  final int createdAt;
  final Map<String, List<CharacterCard>> choices;
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'packName': packName,
    'createdAt': createdAt,
    'choices': choices.map(
      (k, v) => MapEntry(k, v.map((c) => c.toJson()).toList()),
    ),
  };
  factory GameCharacter.fromJson(Map<String, dynamic> j) {
    final c = GameCharacter(
      id: j['id'] as String,
      name: j['name'] as String,
      packName: j['packName'] as String,
      createdAt: j['createdAt'] as int,
      choices: (j['choices'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(
          k,
          (v as List)
              .map(
                (c) =>
                    CharacterCard.fromJson(Map<String, dynamic>.from(c as Map)),
              )
              .toList(),
        ),
      ),
    );
    if (c.id.isEmpty ||
        c.name.trim().isEmpty ||
        c.name.length > 80 ||
        c.packName.length > 80 ||
        c.choices.length > 16 ||
        c.choices.entries.any(
          (e) => e.key.length > 80 || e.value.length > 100,
        )) {
      throw const FormatException('Personnage invalide');
    }
    return c;
  }
}
