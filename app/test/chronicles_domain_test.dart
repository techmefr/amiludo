import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_card.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_checks.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_draw.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_export.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_rules.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_run.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_sheet.dart';

import 'chronicles_fixtures.dart';

ChroniclesCard card(
  String id, {
  String type = 't',
  String rarity = 'c',
  Map<String, int> mods = const {},
  List<String> tags = const [],
  List<String> conflicts = const [],
  String? epithet,
}) => ChroniclesCard(
  id: id,
  universe: 'u',
  step: 1,
  type: type,
  rarity: rarity,
  name: id,
  text: id,
  modifiers: mods,
  tags: tags,
  conflicts: conflicts,
  epithet: epithet,
);

void main() {
  final data = syntheticData();
  final step = data.step(0);

  test('the sample file loads and is coherent', () {
    final sample = sampleData();
    expect(chroniclesProblems(sample), isEmpty);
    expect(sample.universes, hasLength(4));
    expect(sample.steps, hasLength(5));
  });

  test('coherence checks report broken data', () {
    final json = sampleJson();
    final cards = json['cartes'] as List;
    cards.add({...(cards.first as Map), 'rarete': 'zz'});
    final problems = chroniclesProblems(ChroniclesData.fromJson(json));
    expect(problems, contains(contains('duplicate id')));
    expect(problems, contains(contains('unknown rarity')));
  });

  test('the full content file is checked when it has 223 cards', () {
    final full = sampleData();
    expect(chroniclesProblems(full), isEmpty);
  }, skip: sampleData().cards.length != 223 ? 'sample content in use' : false);

  test('a booster has five cards and one card per single type', () {
    final draw = ChroniclesDraw(data, seeded(1));
    final fer = data.editions.first;
    for (var i = 0; i < 200; i++) {
      final booster = draw.booster(
        universe: 'u',
        stepIndex: 0,
        edition: fer,
        kept: const [],
      );
      expect(booster, hasLength(5));
      expect(booster.map((c) => c.type).toSet(), hasLength(5));
    }
  });

  test('ten thousand draws follow the rarity weights within 1.5 points', () {
    final draw = ChroniclesDraw(data, seeded(7));
    final counts = {for (final r in rarityIds) r: 0};
    var total = 0;
    for (var i = 0; i < 2000; i++) {
      for (final c in draw.booster(
        universe: 'u',
        stepIndex: 0,
        edition: data.editions.first,
        kept: const [],
      )) {
        counts[c.rarity] = counts[c.rarity]! + 1;
        total++;
      }
    }
    expect(total, 10000);
    for (final r in data.rarities) {
      expect(counts[r.id]! * 100 / total, closeTo(r.weight, 1.5), reason: r.id);
    }
  });

  test('a card of a full type or in conflict is refused', () {
    final kept = [
      KeptCard(card('a', type: 't0', tags: ['x'])),
      KeptCard(card('b', type: 't1')),
    ];
    expect(
      ChroniclesRules.refusal(step, card('c', type: 't0'), kept),
      Refusal.quota,
    );
    expect(
      ChroniclesRules.refusal(
        step,
        card('d', type: 't2', conflicts: ['x']),
        kept,
      ),
      Refusal.conflict,
    );
    expect(
      ChroniclesRules.refusal(
        step,
        card('e', type: 't2', tags: ['y']),
        [KeptCard(card('f', type: 't3', conflicts: ['y']))],
      ),
      Refusal.conflict,
    );
    expect(ChroniclesRules.refusal(step, card('g', type: 't2'), kept), isNull);
  });

  test('a type without a compatible card counts as filled', () {
    final pool = [card('a', type: 't0'), card('b', type: 't1', tags: ['k'])];
    final kept = [KeptCard(card('z', type: 't9', conflicts: ['k']))];
    final missing = ChroniclesRules.missing(step, pool, kept);
    expect(missing.map((q) => q.type), ['t0']);
  });

  test('destiny completes to the minimums with marked cards', () {
    final sample = sampleData();
    final draw = ChroniclesDraw(sample, seeded(3));
    for (var s = 0; s < sample.steps.length; s++) {
      final added = draw.destiny(universe: 'fantasy', stepIndex: s, kept: []);
      expect(added.every((k) => k.destiny), isTrue);
      final pool = sample.poolFor('fantasy', sample.step(s).id);
      expect(
        ChroniclesRules.stepComplete(sample.step(s), pool, added),
        isTrue,
      );
      for (final q in sample.step(s).quotas.where((q) => q.min > 0)) {
        expect(
          ChroniclesRules.count(added, sample.step(s).id, q.type),
          greaterThanOrEqualTo(q.min),
        );
      }
      for (final a in added) {
        expect(added.any((b) => a.card.conflictsWith(b.card)), isFalse);
      }
    }
  });

  test('stats start at 8, ignore destiny cards and stay in 3 to 24', () {
    final kept = [
      KeptCard(card('a', mods: {'for': 2, 'agi': -9})),
      KeptCard(card('b', mods: {'for': 30}), destiny: true),
      KeptCard(card('c', mods: {'int': 40})),
    ];
    final stats = ChroniclesSheet.statsOf(data, kept);
    expect(stats['for'], 10);
    expect(stats['agi'], 3);
    expect(stats['int'], 24);
    expect(stats['cha'], 8);
  });

  test('global rarity is the rounded mean plus a legendary bonus', () {
    ChroniclesRarity of(List<KeptCard> kept) =>
        ChroniclesSheet.rarityOf(data, kept);
    expect(of([KeptCard(card('a')), KeptCard(card('b', rarity: 'u'))]).id, 'u');
    expect(of([KeptCard(card('a', rarity: 'm'), destiny: true)]).id, 'c');
    expect(
      of([KeptCard(card('a', rarity: 'c')), KeptCard(card('b', rarity: 'l'))]).id,
      'e',
    );
    expect(of([KeptCard(card('a', rarity: 'm'))]).id, 'm');
  });

  test('the epithet comes from the rarest card that has one', () {
    String epithet(List<KeptCard> kept) =>
        ChroniclesSheet.epithetOf(data, 'u', kept);
    expect(epithet([KeptCard(card('a'))]), 'Default');
    expect(
      epithet([
        KeptCard(card('a', epithet: 'Low')),
        KeptCard(card('b', rarity: 'e', epithet: 'High')),
        KeptCard(card('c', rarity: 'm', epithet: 'Chosen'), destiny: true),
      ]),
      'High',
    );
  });

  test('a played game ends with a coherent sheet and exports', () {
    final sample = sampleData();
    final run = playThrough(sample, seeded(11));
    expect(run.phase, ChroniclesPhase.done);
    for (var s = 0; s < sample.steps.length; s++) {
      expect(
        ChroniclesRules.stepComplete(sample.step(s), sample.poolFor('fantasy', sample.step(s).id), run.kept),
        isTrue,
      );
    }
    final sheet = ChroniclesSheet.build(sample, 'fantasy', run.kept);
    expect(sheet.sections, hasLength(5));
    expect(sheet.name, isNotEmpty);
    expect(ChroniclesExport.text(sheet, sample), contains(sheet.name));
    final json = jsonDecode(ChroniclesExport.jsonText(sheet)) as Map;
    expect(json['universe'], 'fantasy');
    expect((json['cards'] as List).length, run.kept.length);
  });

  test('a run survives a save and a resume', () {
    final sample = sampleData();
    final run = ChroniclesRun('fantasy')..next(sample);
    run.openBooster(sample, ChroniclesDraw(sample, seeded(5)), 'vent');
    run.keep(sample);
    final restored = ChroniclesRun.fromJson(
      jsonDecode(jsonEncode(run.toJson())) as Map<String, dynamic>,
      sample,
    );
    expect(restored.toJson(), run.toJson());
    expect(restored.current?.id, run.current?.id);
  });

  test('an invalid stored run is rejected', () {
    final sample = sampleData();
    expect(
      () => ChroniclesRun.fromJson({
        'universe': 'nowhere',
        'step': 0,
        'phase': 'edition',
        'edition': null,
        'booster': <String>[],
        'position': 0,
        'kept': <Object>[],
        'seen': <String>[],
      }, sample),
      throwsA(anything),
    );
  });
}
