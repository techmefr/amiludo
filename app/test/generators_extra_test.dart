import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/generator_content.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/generator_recipes.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/tool_catalog.dart';

GeneratorEngine engine(String language, int seed) => GeneratorEngine(
  GeneratorTables.decode(
    File('assets/generators/$language.json').readAsStringSync(),
  ),
  random: RandomTools(random: Random(seed)),
);

void main() {
  test('every recipe is listed in the story tools', () {
    for (final id in generatorRecipes.keys) {
      final tool = toolDefinitions.where((t) => t.id == id);
      expect(tool, hasLength(1), reason: id);
      expect(tool.single.category, 'story');
    }
  });

  for (final language in ['en', 'fr']) {
    for (final id in generatorRecipes.keys) {
      test('$id fills every section in $language', () {
        for (var seed = 0; seed < 25; seed++) {
          final sheet = engine(language, seed).generate(id);
          expect(sheet.title.trim(), isNotEmpty);
          expect(sheet.sections.length, generatorRecipes[id]!.sections.length);
          for (final s in sheet.sections) {
            expect(s.label.trim(), isNotEmpty);
            expect(s.lines, isNotEmpty);
            expect(s.lines.every((l) => l.trim().isNotEmpty), isTrue);
          }
        }
      });
    }
  }

  test('weather effects never repeat in one draw', () {
    for (var seed = 0; seed < 25; seed++) {
      final lines = engine('en', seed).generate('weather').sections[2].lines;
      expect(lines.toSet().length, lines.length);
    }
  });

  test('a place name is one word', () {
    for (var seed = 0; seed < 25; seed++) {
      expect(engine('en', seed).generate('place').title.contains(' '), isFalse);
    }
  });
}
