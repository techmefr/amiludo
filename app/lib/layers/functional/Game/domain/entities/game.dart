import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';

import 'dart:convert';

String newId() => DateTime.now().microsecondsSinceEpoch.toString();

enum GameError implements Exception { invalidPlayers }

String numberText(num value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');

class Player {
  const Player({
    required this.id,
    required this.name,
    required this.color,
    this.resources = const {},
    this.statuses = const {},
  });
  final String id;
  final String name;
  final int color;
  final Map<String, double> resources;
  final Map<String, int> statuses;
  Player withResource(String key, double value) => Player(
    id: id,
    name: name,
    color: color,
    resources: {...resources, key: value},
    statuses: statuses,
  );
  Player withStatus(String key, int stacks) => Player(
    id: id,
    name: name,
    color: color,
    resources: resources,
    statuses: {
      for (final e in statuses.entries)
        if (e.key != key) e.key: e.value,
      if (stacks > 0) key: stacks,
    },
  );
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'resources': resources,
    'statuses': statuses,
  };
  factory Player.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    if (name.trim().isEmpty || name.length > 40) {
      throw const FormatException('Nom de joueur invalide');
    }
    final resources = (json['resources'] as Map<String, dynamic>? ?? {}).map(
      (k, v) => MapEntry(k, (v as num).toDouble()),
    );
    if (resources.length > 100 || resources.values.any((v) => !v.isFinite)) {
      throw const FormatException('Compteurs invalides');
    }
    final statuses = (json['statuses'] as Map<String, dynamic>? ?? {}).map(
      (k, v) => MapEntry(k, v as int),
    );
    if (statuses.length > 100 || statuses.values.any((v) => v < 1)) {
      throw const FormatException('Statuts invalides');
    }
    return Player(
      id: json['id'] as String,
      name: name,
      color: json['color'] as int,
      resources: resources,
      statuses: statuses,
    );
  }
}

class ScoreEntry {
  const ScoreEntry({
    required this.id,
    required this.playerId,
    required this.value,
    required this.round,
    required this.category,
    required this.createdAt,
  });
  final String id, playerId, category;
  final double value;
  final int round, createdAt;
  Map<String, Object?> toJson() => {
    'id': id,
    'playerId': playerId,
    'value': value,
    'round': round,
    'category': category,
    'createdAt': createdAt,
  };
  factory ScoreEntry.fromJson(Map<String, dynamic> json) {
    final value = (json['value'] as num).toDouble();
    if (!value.isFinite || value.abs() > 1000000000) {
      throw const FormatException('Score invalide');
    }
    return ScoreEntry(
      id: json['id'] as String,
      playerId: json['playerId'] as String,
      value: value,
      round: json['round'] as int,
      category: json['category'] as String,
      createdAt: json['createdAt'] as int,
    );
  }
}

class GameSession {
  const GameSession({
    required this.id,
    required this.title,
    required this.players,
    required this.createdAt,
    this.entries = const [],
    this.cursor = 0,
    this.round = 1,
    this.activeIndex = 0,
    this.target = 0,
    this.lowestWins = false,
    this.cooperative = false,
    this.categories = const ['Points'],
    this.notes = '',
    this.finishedAt,
    this.pack,
  });
  final String id, title, notes;
  final GameTemplate? pack;
  final List<Player> players;
  final List<ScoreEntry> entries;
  final List<String> categories;
  final int cursor, round, activeIndex, createdAt;
  final double target;
  final bool lowestWins, cooperative;
  final int? finishedAt;
  Iterable<ScoreEntry> get appliedEntries => entries.take(cursor);
  double score(String playerId, {int? inRound, String? category}) =>
      appliedEntries
          .where(
            (e) =>
                e.playerId == playerId &&
                (inRound == null || e.round == inRound) &&
                (category == null || e.category == category),
          )
          .fold(0, (sum, e) => sum + e.value);
  List<Player> get ranking {
    final result = [...players];
    result.sort((a, b) {
      final value = score(a.id).compareTo(score(b.id));
      return lowestWins ? value : -value;
    });
    return result;
  }

  List<Player> get winners {
    final sorted = ranking;
    return sorted.where((p) => score(p.id) == score(sorted.first.id)).toList();
  }

  bool get objectiveReached =>
      target > 0 &&
      (cooperative
          ? players.fold<double>(0, (sum, p) => sum + score(p.id)) >= target
          : players.any((p) => score(p.id) >= target));
  GameSession copyWith({
    List<Player>? players,
    List<ScoreEntry>? entries,
    int? cursor,
    int? round,
    int? activeIndex,
    String? notes,
    int? finishedAt,
  }) => GameSession(
    id: id,
    title: title,
    pack: pack,
    players: players ?? this.players,
    entries: entries ?? this.entries,
    cursor: cursor ?? this.cursor,
    round: round ?? this.round,
    activeIndex: activeIndex ?? this.activeIndex,
    target: target,
    lowestWins: lowestWins,
    cooperative: cooperative,
    categories: categories,
    notes: notes ?? this.notes,
    createdAt: createdAt,
    finishedAt: finishedAt ?? this.finishedAt,
  );
  GameSession addScore(String playerId, double value, String category) {
    if (finishedAt != null) throw StateError('Cette partie est terminée');
    if (!players.any((p) => p.id == playerId) ||
        !categories.contains(category) ||
        !value.isFinite ||
        value.abs() > 1000000000) {
      throw ArgumentError('Score invalide');
    }
    final updated = [
      ...entries.take(cursor),
      ScoreEntry(
        id: newId(),
        playerId: playerId,
        value: value,
        round: round,
        category: category,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    ];
    return copyWith(entries: updated, cursor: updated.length);
  }

  GameSession updatePlayer(String playerId, Player Function(Player) update) {
    if (finishedAt != null) throw StateError('Cette partie est terminée');
    if (!players.any((p) => p.id == playerId)) {
      throw ArgumentError('Joueur inconnu');
    }
    return copyWith(
      players: [for (final p in players) p.id == playerId ? update(p) : p],
    );
  }

  GameSession undo() => copyWith(cursor: cursor > 0 ? cursor - 1 : 0);
  GameSession redo() =>
      copyWith(cursor: cursor < entries.length ? cursor + 1 : cursor);
  GameSession nextTurn({bool reverse = false}) => copyWith(
    activeIndex: (activeIndex + (reverse ? -1 : 1)) % players.length,
  );
  Map<String, Object?> toJson() => {
    'id': id,
    'pack': pack?.toJson(),
    'title': title,
    'players': players.map((p) => p.toJson()).toList(),
    'entries': entries.map((e) => e.toJson()).toList(),
    'cursor': cursor,
    'round': round,
    'activeIndex': activeIndex,
    'target': target,
    'lowestWins': lowestWins,
    'cooperative': cooperative,
    'categories': categories,
    'notes': notes,
    'createdAt': createdAt,
    'finishedAt': finishedAt,
  };
  factory GameSession.fromJson(Map<String, dynamic> json) {
    final players = (json['players'] as List)
        .map((p) => Player.fromJson(Map<String, dynamic>.from(p as Map)))
        .toList();
    final entries = (json['entries'] as List? ?? [])
        .map((e) => ScoreEntry.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final categories = List<String>.from(
      json['categories'] as List? ?? ['Points'],
    );
    final cursor = json['cursor'] as int? ?? entries.length,
        active = json['activeIndex'] as int? ?? 0,
        round = json['round'] as int? ?? 1;
    if (players.isEmpty ||
        players.length > 32 ||
        players.map((p) => p.id).toSet().length != players.length ||
        categories.isEmpty ||
        categories.length > 32 ||
        cursor < 0 ||
        cursor > entries.length ||
        active < 0 ||
        active >= players.length ||
        round < 1 ||
        entries.any(
          (e) =>
              !players.any((p) => p.id == e.playerId) ||
              !categories.contains(e.category) ||
              e.round < 1,
        )) {
      throw const FormatException('Partie invalide');
    }
    final target = (json['target'] as num? ?? 0).toDouble();
    if (!target.isFinite ||
        target < 0 ||
        categories.toSet().length != categories.length ||
        categories.any((c) => c.trim().isEmpty || c.length > 40) ||
        (json['title'] as String).trim().isEmpty ||
        (json['title'] as String).length > 80 ||
        (json['notes'] as String? ?? '').length > 4000) {
      throw const FormatException('Configuration de partie invalide');
    }
    return GameSession(
      id: json['id'] as String,
      title: json['title'] as String,
      pack: json['pack'] == null
          ? null
          : GameTemplate.fromJson(
              Map<String, dynamic>.from(json['pack'] as Map),
            ),
      players: players,
      entries: entries,
      cursor: cursor,
      round: round,
      activeIndex: active,
      categories: categories,
      target: (json['target'] as num? ?? 0).toDouble(),
      lowestWins: json['lowestWins'] as bool? ?? false,
      cooperative: json['cooperative'] as bool? ?? false,
      notes: json['notes'] as String? ?? '',
      createdAt: json['createdAt'] as int,
      finishedAt: json['finishedAt'] as int?,
    );
  }
  String toCsv() {
    final rows = <List<String>>[
      ['Joueur', ...List.generate(round, (r) => 'Manche ${r + 1}'), 'Total'],
      ...players.map(
        (p) => [
          p.name,
          ...List.generate(
            round,
            (r) => numberText(score(p.id, inRound: r + 1)),
          ),
          numberText(score(p.id)),
        ],
      ),
    ];
    return rows
        .map((r) => r.map((v) => '"${v.replaceAll('"', '""')}"').join(';'))
        .join('\r\n');
  }

  String export() => jsonEncode({
    'format': 'table-companion-game',
    'version': 1,
    'game': toJson(),
  });
}
