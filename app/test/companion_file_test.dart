import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/companion_file.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';

const template = GameTemplate(
  id: 'my-game',
  name: 'My game',
  description: 'Private description',
  rulesNotes: 'Private rules',
  rulesUrl: 'https://example.com/rules',
  target: 50,
  lowestWins: true,
  seconds: 90,
  bricks: [
    Brick(id: 'b1', type: 'counter', settings: {'start': 3}),
    Brick(id: 'b2', type: 'timer'),
  ],
);

CompanionFileProblem problemOf(String source) {
  try {
    CompanionFile.decode(source);
  } on CompanionFileException catch (e) {
    return e.problem;
  }
  fail('expected a CompanionFileException');
}

void main() {
  test('the file carries only identity, settings and bricks', () {
    final json = jsonDecode(CompanionFile.encode(template)) as Map;
    expect(json.keys.toSet(), {
      'format',
      'version',
      'id',
      'name',
      'settings',
      'bricks',
    });
    expect(json['format'], 'amiludo-companion');
    expect(json['version'], 1);
    final text = CompanionFile.encode(template);
    expect(text.contains('Private rules'), isFalse);
    expect(text.contains('Private description'), isFalse);
    expect(text.contains('example.com'), isFalse);
  });

  test('a round trip keeps bricks and settings', () {
    final back = CompanionFile.decode(CompanionFile.encode(template));
    expect(back.id, 'my-game');
    expect(back.name, 'My game');
    expect(back.target, 50);
    expect(back.lowestWins, isTrue);
    expect(back.seconds, 90);
    expect(back.bricks.map((b) => b.id), ['b1', 'b2']);
    expect(back.bricks.first.settings['start'], 3);
    expect(back.description, isEmpty);
    expect(back.rulesNotes, isEmpty);
  });

  test('text that is not JSON is refused', () {
    expect(problemOf('nope {'), CompanionFileProblem.notJson);
  });

  test('another format or a bare list is refused', () {
    expect(problemOf('[]'), CompanionFileProblem.wrongFormat);
    expect(
      problemOf(jsonEncode({'format': 'table-companion-template'})),
      CompanionFileProblem.wrongFormat,
    );
  });

  test('an unknown version is refused', () {
    final data = jsonDecode(CompanionFile.encode(template)) as Map;
    for (final version in [0, 2, '1', null]) {
      expect(
        problemOf(jsonEncode({...data, 'version': version})),
        CompanionFileProblem.wrongVersion,
      );
    }
  });

  test('invalid content is refused', () {
    final data = jsonDecode(CompanionFile.encode(template)) as Map;
    expect(
      problemOf(jsonEncode({...data, 'id': 'bad id!'})),
      CompanionFileProblem.invalid,
    );
    expect(
      problemOf(jsonEncode({...data, 'settings': 'x'})),
      CompanionFileProblem.invalid,
    );
    expect(
      problemOf(jsonEncode({...data, 'bricks': 'x'})),
      CompanionFileProblem.invalid,
    );
    expect(
      problemOf(
        jsonEncode({
          ...data,
          'settings': {'modules': ['unknown']},
        }),
      ),
      CompanionFileProblem.invalid,
    );
  });

  test('a built-in identifier is reserved', () {
    final data = jsonDecode(CompanionFile.encode(template)) as Map;
    expect(
      problemOf(jsonEncode({...data, 'id': 'free'})),
      CompanionFileProblem.reserved,
    );
  });
}
