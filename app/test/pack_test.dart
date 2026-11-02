import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:table_companion/layers/functional/Templates/domain/game_template.dart';
import 'package:table_companion/layers/functional/Templates/domain/pack_catalog.dart';
import 'package:table_companion/layers/functional/Templates/domain/pack_components.dart';
import 'package:table_companion/layers/functional/Templates/domain/character_pack.dart';
import 'package:table_companion/layers/functional/Random/domain/character_draft.dart';
import 'package:table_companion/layers/functional/Random/domain/random_tools.dart';
import 'package:table_companion/layers/functional/Workspace/domain/workspace.dart';
import 'package:table_companion/layers/functional/Game/domain/game.dart';

void main() {
  final packs = PackCatalog.decode(
    File('assets/community/catalog.json').readAsStringSync(),
  );
  test('every public pack validates and survives portable JSON', () {
    expect(packs.length, 3);
    for (final p in packs) {
      expect(
        GameTemplate.fromJson(jsonDecode(jsonEncode(p.toJson()))).toJson(),
        p.toJson(),
      );
      expect(p.author, isNotEmpty);
      expect(p.license, isNotEmpty);
    }
  });
  test('legacy templates retain score and timer configuration', () {
    final p = GameTemplate.fromJson({
      'id': 'legacy',
      'name': 'Old',
      'categories': ['Points'],
      'seconds': 300,
    });
    expect(p.dice, isEmpty);
    expect(p.creation, isEmpty);
    expect(p.seconds, 300);
  });
  test(
    'linear, sets, progression, threshold and lookup have exact results',
    () {
      expect(const ScoreRule(name: 'n', factor: -2).calculate(2.5), -5);
      expect(
        const ScoreRule(
          name: 'n',
          kind: 'sets',
          factor: 5,
          step: 3,
        ).calculate(8),
        10,
      );
      expect(const ScoreRule(name: 'n', kind: 'triangular').calculate(4), 10);
      expect(
        const ScoreRule(
          name: 'n',
          kind: 'threshold',
          factor: 10,
          step: 5,
        ).calculate(4),
        0,
      );
      expect(
        const ScoreRule(
          name: 'n',
          kind: 'threshold',
          factor: 10,
          step: 5,
          bonus: -2,
        ).calculate(5),
        8,
      );
      expect(
        const ScoreRule(
          name: 'n',
          kind: 'lookup',
          table: [0, 2, 5],
        ).calculate(2),
        5,
      );
    },
  );
  test('invalid counts, nonfinite values, unsafe links and absent categories rejected', () {
    final p = packs.firstWhere((p) => p.id == 'example-expedition');
    expect(
      () => GameTemplate.fromJson({
        ...p.toJson(),
        'rulesUrl': 'javascript:alert(1)',
      }),
      throwsFormatException,
    );
    expect(
      () => GameDie.fromJson({'name': 'd', 'count': 0, 'faces': []}),
      throwsFormatException,
    );
    expect(
      () => ScoreRule.fromJson({'name': 'x', 'step': 0}),
      throwsFormatException,
    );
    expect(
      () => const ScoreRule(name: 'n', kind: 'sets').calculate(-1),
      throwsFormatException,
    );
    expect(
      () => const ScoreRule(name: 'n', kind: 'lookup', table: [0]).calculate(1),
      throwsFormatException,
    );
    expect(
      () => GameTemplate.fromJson({
        ...p.toJson(),
        'categories': ['unrelated'],
      }),
      throwsFormatException,
    );
  });
  test('game snapshots freeze packs across later library modifications', () {
    final p = packs.first;
    final g = GameSession(
      id: 'g',
      title: 'g',
      players: const [Player(id: 'a', name: 'A', color: 0)],
      createdAt: 1,
      pack: p,
      categories: p.categories,
    );
    final restored = GameSession.fromJson(
      jsonDecode(jsonEncode(g.addScore('a', 3, p.categories.first).toJson())),
    );
    expect(restored.pack!.toJson(), p.toJson());
    expect(restored.undo().pack!.name, p.name);
  });
  test('reapplying final category total never counts it twice', () {
    final p = packs.firstWhere((p) => p.id == 'example-expedition');
    var g = GameSession(
      id: 'g',
      title: 'g',
      players: const [Player(id: 'a', name: 'A', color: 0)],
      createdAt: 1,
      pack: p,
      categories: p.categories,
    );
    final r = p.scoring.first;
    for (final count in [6.0, 6.0, 9.0]) {
      g = g.addScore(
        'a',
        r.calculate(count) - g.score('a', inRound: g.round, category: r.name),
        r.name,
      );
    }
    expect(g.score('a'), 15);
    expect(g.undo().score('a'), 10);
  });
  test(
    'boosters draw without repeats, enforce keep limits and support two races',
    () {
      final p = packs.firstWhere((p) => p.id == 'example-booster');
      final d = CharacterDraft(
        p.creation,
        random: RandomTools(random: Random(3)),
      );
      expect(d.offers.first.length, 4);
      expect(d.offers.first.map((c) => c.name).toSet().length, 4);
      expect(() => d.choose({}), throwsFormatException);
      expect(() => d.choose({0, 1, 2}), throwsFormatException);
      d.choose({0, 1});
      expect(d.choices['Races']!.length, 2);
      expect(d.index, 1);
      expect(() => d.choose({99}), throwsFormatException);
    },
  );
  test(
    'list mode offers every card and final sheet survives backup restore',
    () {
      final p = packs.firstWhere((p) => p.id == 'example-booster');
      final d = CharacterDraft(p.creation, boosters: false);
      expect(d.offers.first.length, p.creation.first.cards.length);
      while (!d.complete) {
        d.choose({0});
      }
      final c = GameCharacter(
        id: 'c',
        name: 'A',
        packName: p.name,
        createdAt: 1,
        choices: d.choices,
      );
      final ws = Workspace(characters: [c], templates: [p]);
      final restored = Workspace.fromJson(jsonDecode(ws.export()));
      expect(restored.characters.single.toJson(), c.toJson());
      expect(() => d.choose({0}), throwsStateError);
    },
  );
  test('character categories reject impossible booster and keep sizes', () {
    final c = packs.firstWhere((p) => p.id == 'example-booster').creation.first;
    expect(
      () => CreationCategory.fromJson({...c.toJson(), 'draw': 99}),
      throwsFormatException,
    );
    expect(
      () => CreationCategory.fromJson({...c.toJson(), 'keepMax': 99}),
      throwsFormatException,
    );
  });
  test('public catalogue rejects duplicates and reserved builtin ids', () {
    final p = packs.first.toJson();
    expect(
      () => PackCatalog.decode(
        jsonEncode({
          'format': 'table-companion-catalog',
          'version': 1,
          'packs': [p, p],
        }),
      ),
      throwsFormatException,
    );
    expect(
      () => PackCatalog.decode(
        jsonEncode({
          'format': 'table-companion-catalog',
          'version': 1,
          'packs': [
            {...p, 'id': 'free'},
          ],
        }),
      ),
      throwsFormatException,
    );
  });
}
