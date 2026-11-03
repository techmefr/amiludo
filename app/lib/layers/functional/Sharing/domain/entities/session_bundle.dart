import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';

const sessionFormat = 'amiludo-session';

class SessionBundle {
  const SessionBundle({
    this.games = const [],
    this.templates = const [],
    this.characters = const [],
    this.playerNames = const [],
  });

  final List<ShelfGame> games;
  final List<GameTemplate> templates;
  final List<GameCharacter> characters;
  final List<String> playerNames;

  bool get isEmpty => games.isEmpty && templates.isEmpty && characters.isEmpty;

  Map<String, Object?> toJson() => {
    'format': sessionFormat,
    'version': 1,
    'games': games.map((g) => g.toJson()).toList(),
    'templates': templates.map((t) => t.toJson()).toList(),
    'characters': characters.map((c) => c.toJson()).toList(),
    'playerNames': playerNames,
  };

  factory SessionBundle.fromJson(Map<String, dynamic> j) {
    if (j['format'] != sessionFormat || j['version'] != 1) {
      throw const FormatException('Ce QR code n’est pas une session amiLudo.');
    }
    List<T> parse<T>(String key, T Function(Map<String, dynamic>) read) =>
        (j[key] as List? ?? const [])
            .map((v) => read(Map<String, dynamic>.from(v as Map)))
            .toList();
    final names = List<String>.from(j['playerNames'] as List? ?? const []);
    if (names.length > 32 || names.any((n) => n.trim().isEmpty)) {
      throw const FormatException('Joueurs invalides');
    }
    return SessionBundle(
      games: parse('games', ShelfGame.fromJson),
      templates: parse('templates', GameTemplate.fromJson),
      characters: parse('characters', GameCharacter.fromJson),
      playerNames: names,
    );
  }
}
