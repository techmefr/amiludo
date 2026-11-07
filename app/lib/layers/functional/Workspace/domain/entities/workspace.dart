import 'dart:convert';

import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Timer/domain/entities/game_clock.dart';

class Workspace {
  const Workspace({
    this.appearance = const Appearance(),
    this.profiles = const [],
    this.games = const [],
    this.templates = const [],
    this.characters = const [],
    this.playerNames = const ['Camille', 'Alex', 'Léa', 'Sam'],
    this.favorites = const [
      'dice',
      'picker',
      'scores',
      'timer',
      'teams',
      'wheel',
    ],
    this.currentId,
    this.clock = const GameClock(),
    this.banks = const {},
    this.sessionClocks = const {},
    this.bankMode = false,
    this.reverse = false,
    this.nickname = '',
    this.lastTool,
  });
  final String nickname;
  final String? lastTool;
  final Appearance appearance;
  final List<StyleProfile> profiles;
  final List<GameSession> games;
  final List<GameTemplate> templates;
  final List<GameCharacter> characters;
  final List<String> playerNames, favorites;
  final String? currentId;
  final GameClock clock;
  final Map<String, int> banks;
  final Map<String, ClockSnapshot> sessionClocks;
  final bool bankMode, reverse;
  GameSession? get current {
    for (final g in games) {
      if (g.id == currentId) return g;
    }
    return null;
  }

  Map<String, ClockSnapshot> clocksAt(int now) => {
    ...sessionClocks,
    ?currentId: ClockSnapshot(clock.pause(now), bankMode, reverse),
  };

  Workspace withGame(GameSession game) =>
      copyWith(games: [game, ...games.where((g) => g.id != game.id)]);

  Workspace copyWith({
    Appearance? appearance,
    List<StyleProfile>? profiles,
    List<GameSession>? games,
    List<GameTemplate>? templates,
    List<GameCharacter>? characters,
    List<String>? playerNames,
    List<String>? favorites,
    String? currentId,
    GameClock? clock,
    Map<String, int>? banks,
    Map<String, ClockSnapshot>? sessionClocks,
    bool? bankMode,
    bool? reverse,
    String? nickname,
    String? lastTool,
  }) => Workspace(
    nickname: nickname ?? this.nickname,
    lastTool: lastTool ?? this.lastTool,
    appearance: appearance ?? this.appearance,
    profiles: profiles ?? this.profiles,
    games: games ?? this.games,
    templates: templates ?? this.templates,
    characters: characters ?? this.characters,
    playerNames: playerNames ?? this.playerNames,
    favorites: favorites ?? this.favorites,
    currentId: currentId ?? this.currentId,
    clock: clock ?? this.clock,
    banks: banks ?? this.banks,
    sessionClocks: sessionClocks ?? this.sessionClocks,
    bankMode: bankMode ?? this.bankMode,
    reverse: reverse ?? this.reverse,
  );
  Map<String, Object?> toJson() => {
    'format': 'table-companion',
    'version': 1,
    'appearance': appearance.toJson(),
    'profiles': profiles.map((p) => p.toJson()).toList(),
    'games': games.map((g) => g.toJson()).toList(),
    'templates': templates.map((t) => t.toJson()).toList(),
    'characters': characters.map((c) => c.toJson()).toList(),
    'playerNames': playerNames,
    'favorites': favorites,
    'currentId': currentId,
    'clock': clock.toJson(),
    'banks': banks,
    'sessionClocks': sessionClocks.map((k, v) => MapEntry(k, v.toJson())),
    'bankMode': bankMode,
    'reverse': reverse,
    'nickname': nickname,
    'lastTool': ?lastTool,
  };
  String export() => jsonEncode(toJson());
  factory Workspace.fromJson(Map<String, dynamic> j) {
    if (j['format'] != 'table-companion' || j['version'] != 1) {
      throw const FormatException('Version de sauvegarde incompatible');
    }
    final games = (j['games'] as List)
        .map((g) => GameSession.fromJson(Map<String, dynamic>.from(g as Map)))
        .toList();
    if (games.length > 10000 ||
        games.map((g) => g.id).toSet().length != games.length) {
      throw const FormatException('Bibliothèque invalide');
    }
    return Workspace(
      appearance: Appearance.fromJson(
        Map<String, dynamic>.from(j['appearance'] as Map),
      ),
      profiles: _list(j['profiles'], StyleProfile.fromJson),
      games: games,
      characters: _list(j['characters'], GameCharacter.fromJson),
      templates: _list(j['templates'], GameTemplate.fromJson),
      nickname: (j['nickname'] as String? ?? '').trim(),
      lastTool: j['lastTool'] as String?,
      playerNames: List<String>.from(j['playerNames'] as List? ?? []),
      favorites: List<String>.from(j['favorites'] as List? ?? []),
      currentId: j['currentId'] as String?,
      clock: j['clock'] == null
          ? const GameClock()
          : GameClock.fromJson(Map<String, dynamic>.from(j['clock'] as Map)),
      banks: (j['banks'] as Map<String, dynamic>? ?? {}).map(
        (k, v) => MapEntry(k, v as int),
      ),
      sessionClocks: (j['sessionClocks'] as Map<String, dynamic>? ?? {}).map(
        (k, v) => MapEntry(
          k,
          ClockSnapshot.fromJson(Map<String, dynamic>.from(v as Map)),
        ),
      ),
      bankMode: j['bankMode'] as bool? ?? false,
      reverse: j['reverse'] as bool? ?? false,
    );
  }
}

List<T> _list<T>(Object? raw, T Function(Map<String, dynamic>) parse) =>
    (raw as List? ?? const [])
        .map((v) => parse(Map<String, dynamic>.from(v as Map)))
        .toList();
