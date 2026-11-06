import 'dart:convert';

import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';

enum CompanionFileProblem {
  notJson,
  wrongFormat,
  wrongVersion,
  invalid,
  reserved,
}

class CompanionFileException implements Exception {
  const CompanionFileException(this.problem);
  final CompanionFileProblem problem;

  @override
  String toString() => 'CompanionFileException(${problem.name})';
}

class CompanionFile {
  static const format = 'amiludo-companion';
  static const version = 1;

  static String encode(GameTemplate template) => jsonEncode({
    'format': format,
    'version': version,
    'id': template.id,
    'name': template.name,
    'settings': {
      'modules': template.modules,
      'categories': template.categories,
      'target': template.target,
      'lowestWins': template.lowestWins,
      'cooperative': template.cooperative,
      'seconds': template.seconds,
    },
    'bricks': template.bricks.map((b) => b.toJson()).toList(),
  });

  static GameTemplate decode(String source) {
    final Object? parsed;
    try {
      parsed = jsonDecode(source);
    } on FormatException {
      throw const CompanionFileException(CompanionFileProblem.notJson);
    }
    if (parsed is! Map || parsed['format'] != format) {
      throw const CompanionFileException(CompanionFileProblem.wrongFormat);
    }
    final fileVersion = parsed['version'];
    if (fileVersion is! int || fileVersion < 1 || fileVersion > version) {
      throw const CompanionFileException(CompanionFileProblem.wrongVersion);
    }
    final GameTemplate template;
    try {
      template = GameTemplate.fromJson({
        'id': parsed['id'],
        'name': parsed['name'],
        ...Map<String, dynamic>.from(parsed['settings'] as Map),
        'bricks': parsed['bricks'] ?? const [],
      });
    } on Object {
      throw const CompanionFileException(CompanionFileProblem.invalid);
    }
    if (GameTemplate.builtIn.any((t) => t.id == template.id)) {
      throw const CompanionFileException(CompanionFileProblem.reserved);
    }
    return template;
  }
}
