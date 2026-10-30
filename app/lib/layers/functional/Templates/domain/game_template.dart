class GameTemplate {
  const GameTemplate({
    required this.id,
    required this.name,
    this.description = '',
    this.categories = const ['Points'],
    this.target = 0,
    this.lowestWins = false,
    this.cooperative = false,
    this.seconds = 150,
    this.author = '',
    this.license = 'MIT',
  });
  final String id, name, description, author, license;
  final List<String> categories;
  final double target;
  final bool lowestWins, cooperative;
  final int seconds;
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'categories': categories,
    'target': target,
    'lowestWins': lowestWins,
    'cooperative': cooperative,
    'seconds': seconds,
    'author': author,
    'license': license,
  };
  factory GameTemplate.fromJson(Map<String, dynamic> j) {
    final result = GameTemplate(
      id: j['id'] as String,
      name: j['name'] as String,
      description: j['description'] as String? ?? '',
      categories: List<String>.from(j['categories'] as List? ?? ['Points']),
      target: (j['target'] as num? ?? 0).toDouble(),
      lowestWins: j['lowestWins'] as bool? ?? false,
      cooperative: j['cooperative'] as bool? ?? false,
      seconds: j['seconds'] as int? ?? 150,
      author: j['author'] as String? ?? '',
      license: j['license'] as String? ?? 'MIT',
    );
    if (result.name.trim().isEmpty ||
        result.name.length > 80 ||
        result.categories.isEmpty ||
        result.categories.length > 32 ||
        result.categories.any((c) => c.trim().isEmpty || c.length > 40) ||
        !result.target.isFinite ||
        result.target < 0 ||
        result.seconds < 1 ||
        result.seconds > 86400) {
      throw const FormatException('Modèle invalide');
    }
    return result;
  }
  static const builtIn = [
    GameTemplate(
      id: 'free',
      name: 'Table classique',
      description: 'Scores libres, manches et tours de jeu.',
    ),
    GameTemplate(
      id: 'race',
      name: 'Course aux points',
      description: 'Le premier joueur à 100 points.',
      target: 100,
    ),
    GameTemplate(
      id: 'cooperative',
      name: 'Objectif commun',
      description: 'Une équipe. Un objectif de 200 points.',
      target: 200,
      cooperative: true,
    ),
    GameTemplate(
      id: 'low',
      name: 'Le moins possible',
      description: 'Le score le plus bas remporte la partie.',
      lowestWins: true,
    ),
    GameTemplate(
      id: 'categories',
      name: 'Points & bonus',
      description: 'Décompte en trois catégories.',
      categories: ['Points', 'Bonus', 'Malus'],
    ),
    GameTemplate(
      id: 'duel',
      name: 'Duel chronométré',
      description: 'Une réserve de 5 minutes par joueur.',
      seconds: 300,
    ),
  ];
}
