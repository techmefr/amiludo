import 'pack_components.dart';
import 'character_pack.dart';

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
    this.revision = '1.0.0',
    this.rulesUrl = '',
    this.rulesNotes = '',
    this.edition = '',
    this.language = 'fr',
    this.englishName = '',
    this.modules = const ['scores', 'timer'],
    this.dice = const [],
    this.roles = const [],
    this.scoring = const [],
    this.creation = const [],
  });
  final String id, name, description, author, license;
  final String revision, rulesUrl, rulesNotes, edition, language;
  final String englishName;
  final List<String> modules;
  final List<GameDie> dice;
  final List<GameRole> roles;
  final List<ScoreRule> scoring;
  final List<CreationCategory> creation;
  final List<String> categories;
  final double target;
  final bool lowestWins, cooperative;
  final int seconds;
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'englishName': englishName.isEmpty ? name : englishName,
    'modules': modules,
    'description': description,
    'categories': categories,
    'target': target,
    'lowestWins': lowestWins,
    'cooperative': cooperative,
    'seconds': seconds,
    'author': author,
    'license': license,
    'revision': revision,
    'rulesUrl': rulesUrl,
    'rulesNotes': rulesNotes,
    'edition': edition,
    'language': language,
    'dice': dice.map((v) => v.toJson()).toList(),
    'roles': roles.map((v) => v.toJson()).toList(),
    'scoring': scoring.map((v) => v.toJson()).toList(),
    'creation': creation.map((v) => v.toJson()).toList(),
  };
  factory GameTemplate.fromJson(Map<String, dynamic> j) {
    final result = GameTemplate(
      id: j['id'] as String,
      name: j['name'] as String,
      englishName: j['englishName'] as String? ?? j['name'] as String,
      modules: List<String>.from(
        j['modules'] as List? ??
            [
              'scores',
              'timer',
              if ((j['dice'] as List? ?? []).isNotEmpty) 'dice',
              if ((j['roles'] as List? ?? []).isNotEmpty) 'roles',
              if ((j['creation'] as List? ?? []).isNotEmpty) 'character',
              if ((j['rulesNotes'] as String? ?? '').isNotEmpty ||
                  (j['rulesUrl'] as String? ?? '').isNotEmpty)
                'rules',
            ],
      ),
      description: j['description'] as String? ?? '',
      categories: List<String>.from(j['categories'] as List? ?? ['Points']),
      target: (j['target'] as num? ?? 0).toDouble(),
      lowestWins: j['lowestWins'] as bool? ?? false,
      cooperative: j['cooperative'] as bool? ?? false,
      seconds: j['seconds'] as int? ?? 150,
      author: j['author'] as String? ?? '',
      license: j['license'] as String? ?? 'MIT',
      revision: j['revision'] as String? ?? '1.0.0',
      rulesUrl: j['rulesUrl'] as String? ?? '',
      rulesNotes: j['rulesNotes'] as String? ?? '',
      edition: j['edition'] as String? ?? '',
      language: j['language'] as String? ?? 'fr',
      dice: (j['dice'] as List? ?? [])
          .map((v) => GameDie.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList(),
      roles: (j['roles'] as List? ?? [])
          .map((v) => GameRole.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList(),
      creation: (j['creation'] as List? ?? [])
          .map(
            (v) =>
                CreationCategory.fromJson(Map<String, dynamic>.from(v as Map)),
          )
          .toList(),
      scoring: (j['scoring'] as List? ?? [])
          .map((v) => ScoreRule.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList(),
    );
    if (result.englishName.trim().isEmpty ||
        result.englishName.length > 80 ||
        result.modules.isEmpty ||
        result.modules.length > 13 ||
        result.modules.toSet().length != result.modules.length ||
        result.modules.any(
          (v) => ![
            'scores',
            'timer',
            'dice',
            'roles',
            'character',
            'rules',
            'picker',
            'teams',
            'wheel',
            'coin',
            'order',
            'number',
            'bag',
          ].contains(v),
        ) ||
        result.language.isEmpty ||
        result.language.length > 20 ||
        result.creation.length > 16 ||
        result.creation.map((c) => c.name).toSet().length !=
            result.creation.length ||
        !RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._-]*$').hasMatch(result.id) ||
        result.id.length > 120 ||
        result.description.length > 500 ||
        result.author.length > 120 ||
        result.license.length > 120 ||
        result.revision.isEmpty ||
        result.revision.length > 40 ||
        result.edition.length > 120 ||
        result.rulesNotes.length > 12000 ||
        !validRuleUrl(result.rulesUrl) ||
        result.dice.length > 16 ||
        result.dice.fold<int>(0, (n, d) => n + d.count) > 64 ||
        result.roles.length > 32 ||
        result.roles.fold<int>(0, (n, d) => n + d.count) > 32 ||
        result.scoring.length > 32 ||
        result.scoring.map((v) => v.name).toSet().length !=
            result.scoring.length ||
        result.scoring.any((v) => !result.categories.contains(v.name)) ||
        result.categories.toSet().length != result.categories.length ||
        result.name.trim().isEmpty ||
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
