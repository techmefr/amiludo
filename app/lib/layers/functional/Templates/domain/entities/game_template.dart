import 'package:amiludo/layers/functional/Templates/domain/entities/pack_components.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';

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
    this.resources = const {},
    this.statuses = const [],
  });
  final String id, name, description, author, license;
  final String revision, rulesUrl, rulesNotes, edition, language;
  final String englishName;
  final List<String> modules;
  final List<GameDie> dice;
  final List<GameRole> roles;
  final List<ScoreRule> scoring;
  final List<CreationCategory> creation;
  final List<String> categories, statuses;
  final Map<String, double> resources;
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
    'resources': resources,
    'statuses': statuses,
  };
  static const knownModules = [
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
  ];

  static List<T> _parse<T>(
    Object? raw,
    T Function(Map<String, dynamic>) read,
  ) => (raw as List? ?? const [])
      .map((v) => read(Map<String, dynamic>.from(v as Map)))
      .toList();

  static List<String> _defaultModules(Map<String, dynamic> j) => [
    'scores',
    'timer',
    if ((j['dice'] as List? ?? []).isNotEmpty) 'dice',
    if ((j['roles'] as List? ?? []).isNotEmpty) 'roles',
    if ((j['creation'] as List? ?? []).isNotEmpty) 'character',
    if ((j['rulesNotes'] as String? ?? '').isNotEmpty ||
        (j['rulesUrl'] as String? ?? '').isNotEmpty)
      'rules',
  ];

  factory GameTemplate.fromJson(Map<String, dynamic> j) {
    final result = GameTemplate(
      id: j['id'] as String,
      name: j['name'] as String,
      englishName: j['englishName'] as String? ?? j['name'] as String,
      modules: List<String>.from(j['modules'] as List? ?? _defaultModules(j)),
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
      dice: _parse(j['dice'], GameDie.fromJson),
      roles: _parse(j['roles'], GameRole.fromJson),
      creation: _parse(j['creation'], CreationCategory.fromJson),
      scoring: _parse(j['scoring'], ScoreRule.fromJson),
      resources: (j['resources'] as Map? ?? const {}).map(
        (k, v) => MapEntry(k as String, (v as num).toDouble()),
      ),
      statuses: List<String>.from(j['statuses'] as List? ?? const []),
    );
    if (!result._validText || !result._validRules || !result._validParts) {
      throw const FormatException('Modèle invalide');
    }
    return result;
  }

  bool get _validText =>
      RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._-]*$').hasMatch(id) &&
      id.length <= 120 &&
      name.trim().isNotEmpty &&
      name.length <= 80 &&
      englishName.trim().isNotEmpty &&
      englishName.length <= 80 &&
      language.isNotEmpty &&
      language.length <= 20 &&
      description.length <= 500 &&
      author.length <= 120 &&
      license.length <= 120 &&
      revision.isNotEmpty &&
      revision.length <= 40 &&
      edition.length <= 120 &&
      rulesNotes.length <= 12000 &&
      validRuleUrl(rulesUrl);

  bool get _validRules =>
      modules.isNotEmpty &&
      modules.length <= 13 &&
      modules.toSet().length == modules.length &&
      modules.every(knownModules.contains) &&
      categories.isNotEmpty &&
      categories.length <= 32 &&
      categories.toSet().length == categories.length &&
      categories.every((c) => c.trim().isNotEmpty && c.length <= 40) &&
      target.isFinite &&
      target >= 0 &&
      seconds >= 1 &&
      seconds <= 86400;

  bool get _validParts =>
      creation.length <= 16 &&
      creation.map((c) => c.name).toSet().length == creation.length &&
      dice.length <= 16 &&
      dice.fold<int>(0, (n, d) => n + d.count) <= 64 &&
      roles.length <= 32 &&
      roles.fold<int>(0, (n, d) => n + d.count) <= 32 &&
      scoring.length <= 32 &&
      scoring.map((v) => v.name).toSet().length == scoring.length &&
      scoring.every((v) => categories.contains(v.name)) &&
      resources.length <= 16 &&
      resources.keys.every((k) => k.trim().isNotEmpty && k.length <= 40) &&
      resources.values.every((v) => v.isFinite) &&
      statuses.length <= 16 &&
      statuses.toSet().length == statuses.length &&
      statuses.every((s) => s.trim().isNotEmpty && s.length <= 40);

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
