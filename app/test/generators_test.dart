import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/generator_content.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';

GeneratorEngine engine(String language, int seed) => GeneratorEngine(
  GeneratorTables.decode(
    File('assets/generators/$language.json').readAsStringSync(),
  ),
  random: RandomTools(random: Random(seed)),
);

void main() {
  for (final language in ['en', 'fr']) {
    for (final id in ['npc', 'tavern', 'encounter']) {
      test('$id generator fills every section in $language', () {
        for (var seed = 0; seed < 25; seed++) {
          final sheet = engine(language, seed).generate(id);
          expect(sheet.title.trim(), isNotEmpty);
          expect(sheet.sections, isNotEmpty);
          for (final s in sheet.sections) {
            expect(s.label.trim(), isNotEmpty);
            expect(s.lines, isNotEmpty);
            expect(s.lines.every((l) => l.trim().isNotEmpty), isTrue);
          }
        }
      });
    }
  }

  test('a tavern menu never repeats a dish', () {
    for (var seed = 0; seed < 25; seed++) {
      final lines = engine('en', seed).tavern().sections.first.lines.toList();
      expect(lines.toSet().length, lines.length);
    }
  });

  test('same seed gives the same result and text export holds the title', () {
    final a = engine('en', 7).npc();
    final b = engine('en', 7).npc();
    expect(a.toText(), b.toText());
    expect(a.toText(), startsWith(a.title));
  });

  test('both languages expose the same tables', () {
    final en = jsonDecode(
      File('assets/generators/en.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final fr = jsonDecode(
      File('assets/generators/fr.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    for (final group in en.keys) {
      expect(
        (fr[group] as Map).keys.toSet(),
        (en[group] as Map).keys.toSet(),
        reason: group,
      );
    }
  });

  test('unknown generator is refused', () {
    expect(() => engine('en', 1).generate('x'), throwsArgumentError);
  });
}
