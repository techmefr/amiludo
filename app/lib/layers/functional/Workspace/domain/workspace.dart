import 'dart:convert';

import '../../../technical/Appearance/appearance.dart';
import '../../Game/domain/game.dart';
import '../../Templates/domain/game_template.dart';
import '../../Timer/domain/game_clock.dart';

class Workspace {
  const Workspace({
    this.appearance = const Appearance(),
    this.profiles = const [],
    this.games = const [],
    this.templates = const [],
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
  });
  final Appearance appearance;
  final List<StyleProfile> profiles;
  final List<GameSession> games;
  final List<GameTemplate> templates;
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

  Workspace copyWith({
    Appearance? appearance,
    List<StyleProfile>? profiles,
    List<GameSession>? games,
    List<GameTemplate>? templates,
    List<String>? playerNames,
    List<String>? favorites,
    String? currentId,
    GameClock? clock,
    Map<String, int>? banks,
    Map<String, ClockSnapshot>? sessionClocks,
    bool? bankMode,
    bool? reverse,
  }) => Workspace(
    appearance: appearance ?? this.appearance,
    profiles: profiles ?? this.profiles,
    games: games ?? this.games,
    templates: templates ?? this.templates,
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
    'playerNames': playerNames,
    'favorites': favorites,
    'currentId': currentId,
    'clock': clock.toJson(),
    'banks': banks,
    'sessionClocks': sessionClocks.map((k, v) => MapEntry(k, v.toJson())),
    'bankMode': bankMode,
    'reverse': reverse,
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
      profiles: (j['profiles'] as List? ?? [])
          .map(
            (p) => StyleProfile.fromJson(Map<String, dynamic>.from(p as Map)),
          )
          .toList(),
      games: games,
      templates: (j['templates'] as List? ?? [])
          .map(
            (t) => GameTemplate.fromJson(Map<String, dynamic>.from(t as Map)),
          )
          .toList(),
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
