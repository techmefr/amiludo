import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/functional/Random/data/chronicles/chronicles_catalog_gateway_impl.dart';
import 'package:amiludo/layers/functional/Random/data/sheet/sheet_tables_gateway_impl.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_use_cases.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_rules.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/character_draft.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/character_sheet.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_checks.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_export.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_fields.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_generator.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_import.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_look.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_tables.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';

import 'chronicles_fixtures.dart';

final tables = SheetTables.fromJson(
  jsonDecode(
        File('assets/chronicles/character-sheet-data.json').readAsStringSync(),
      )
      as Map<String, dynamic>,
);

const universes = ['fantasy', 'scifi', 'cyberpunk', 'gothique'];

SheetGenerator generator(int seed, [SheetTables? t]) =>
    SheetGenerator(t ?? tables, RandomTools(random: Random(seed)));

class _FileBundle extends AssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = File(key).readAsBytesSync();
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }

  @override
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String value) parser,
  ) async => parser(await loadString(key));
}

void main() {
  test('the sheet tables cover every field of every universe', () {
    expect(tables.problems(), isEmpty);
    expect(tables.universes.keys, unorderedEquals(universes));
  });

  test('generating everything fills the five steps coherently', () {
    for (final u in universes) {
      for (var seed = 0; seed < 60; seed++) {
        final g = generator(seed);
        final sheet = g.generateAll(g.blank(u));
        expect(sheet.completedSteps, SheetSpec.stepCount, reason: '$u $seed');
        expect(sheet.of('qualities'), hasLength(5));
        expect(sheet.of('flaws'), hasLength(5));
        expect(SheetChecks.problems(sheet, tables), isEmpty, reason: '$u $seed');
      }
    }
  });

  test('the same seed gives the same sheet', () {
    final a = generator(7).generateAll(generator(7).blank('scifi'));
    final b = generator(7).generateAll(generator(7).blank('scifi'));
    expect(jsonEncode(a.toJson()), jsonEncode(b.toJson()));
  });

  test('a locked field survives a step and a field reroll', () {
    final g = generator(3);
    var sheet = g.edit(g.blank('fantasy'), 'job', ['Cartographe']);
    sheet = g.generateStep(sheet, 1);
    expect(sheet.first('job'), 'Cartographe');
    expect(g.rerollField(sheet, 'job').first('job'), 'Cartographe');
    expect(g.generateAll(sheet).first('job'), 'Cartographe');
    sheet = g.generateAll(sheet.withLock('job', false));
    expect(sheet.isLocked('job'), isFalse);
  });

  test('rerolling one field leaves the others untouched', () {
    final g = generator(11);
    final sheet = g.generateAll(g.blank('gothique'));
    final next = g.rerollField(sheet, 'habits');
    for (final f in SheetSpec.fields.where((f) => f.id != 'habits')) {
      expect(next.of(f.id), sheet.of(f.id), reason: f.id);
    }
    expect(next.of('habits'), isNotEmpty);
  });

  test('rerolling the origin redraws name, place and languages', () {
    final g = generator(5);
    var sheet = g.generateAll(g.blank('cyberpunk'));
    for (var i = 0; i < 10; i++) {
      sheet = g.rerollField(sheet, 'origin');
      expect(SheetChecks.problems(sheet, tables), isEmpty);
      final culture = tables.universe('cyberpunk').culture(sheet.culture)!;
      expect(culture.places, contains(sheet.first('birthPlace')));
    }
  });

  test('a locked name survives an origin reroll', () {
    final g = generator(5);
    var sheet = g.generateAll(g.blank('fantasy'));
    final name = sheet.first('name');
    sheet = g.rerollField(g.edit(sheet, 'name', [name]), 'origin');
    expect(sheet.first('name'), name);
  });

  test('age and birth date stay linked through edits', () {
    final g = generator(2);
    var sheet = g.generateAll(g.blank('fantasy'));
    sheet = g.edit(sheet, 'age', ['40']);
    expect(SheetChecks.problems(sheet, tables), isEmpty);
    sheet = g.edit(g.blank('fantasy'), 'birthDate', ['01/01/1200']);
    expect(sheet.first('age'), '43');
    sheet = g.rerollField(sheet, 'age');
    expect(sheet.first('age'), '43');
    expect(SheetChecks.problems(sheet, tables), isEmpty);
  });

  test('qualities never contradict flaws', () {
    for (var seed = 0; seed < 100; seed++) {
      final g = generator(seed);
      var sheet = g.generateAll(g.blank('scifi'));
      sheet = g.rerollField(g.rerollField(sheet, 'flaws'), 'qualities');
      final clash = tables.oppositesOf(sheet.of('qualities'));
      expect(sheet.of('flaws').any(clash.contains), isFalse);
    }
  });

  test('manual edits are validated and locked', () {
    final g = generator(1);
    final sheet = g.edit(g.blank('fantasy'), 'qualities', [
      'Vif',
      'Poli',
      'Fier',
      'Doux',
      'Vaillant',
    ]);
    expect(sheet.isLocked('qualities'), isTrue);
    expect(() => g.edit(sheet, 'qualities', ['Vif']), throwsFormatException);
    expect(() => g.edit(sheet, 'nope', ['x']), throwsArgumentError);
  });

  test('the sheet survives a JSON round trip and omits empty content', () {
    final g = generator(9);
    final sheet = g.edit(g.generateAll(g.blank('scifi')), 'nickname', ['Nova']);
    final back = CharacterSheet.fromJson(
      jsonDecode(jsonEncode(sheet.toJson())) as Map<String, dynamic>,
    );
    expect(back.toJson(), sheet.toJson());
    expect(back.isLocked('nickname'), isTrue);
    final empty = g.blank('scifi').toJson();
    expect(empty['values'], isEmpty);
    expect(empty.containsKey('locked'), isFalse);
    expect(
      () => CharacterSheet.fromJson({
        'universe': 'scifi',
        'values': {'qualities': List.filled(6, 'x')},
      }),
      throwsFormatException,
    );
  });

  test('characters and drafts omit the sheet when there is none', () {
    final sheet = CharacterSheet(universe: 'fantasy');
    final base = <String, dynamic>{
      'id': 'a',
      'name': 'A',
      'packName': 'P',
      'createdAt': 1,
      'choices': <String, dynamic>{},
    };
    expect(GameCharacter.fromJson(base).toJson().containsKey('sheet'), isFalse);
    final withSheet = GameCharacter.fromJson({...base, 'sheet': sheet.toJson()});
    expect(withSheet.toJson()['sheet'], sheet.toJson());
    final draft = CharacterDraft([
      const CreationCategory(
        name: 'x',
        cards: [CharacterCard(name: 'a'), CharacterCard(name: 'b')],
        draw: 2,
      ),
    ]);
    expect(draft.toJson().containsKey('sheet'), isFalse);
    draft.sheet = sheet.toJson();
    final back = CharacterDraft.fromJson(
      jsonDecode(jsonEncode(draft.toJson())) as Map<String, dynamic>,
    );
    expect(back.sheet, sheet.toJson());
  });

  test('the look links colors and distinctive marks to avatar pieces', () {
    final g = generator(4);
    var sheet = g.blank('cyberpunk');
    sheet = g.edit(sheet, 'skin', ['Peau foncée']);
    sheet = g.edit(sheet, 'eyes', ['Yeux verts']);
    sheet = g.edit(sheet, 'hair', ['Crâne rasé']);
    sheet = g.edit(sheet, 'marks', [
      'Cicatrice de port d\'interface sur la nuque',
    ]);
    final look = SheetLook.of(sheet, tables);
    expect(look.tints, {'skin': 3, 'eyes': 1});
    expect(look.hairless, isTrue);
    expect(look.pieces.single, startsWith('marks.marks-'));
  });

  test('the export lists each step with its labels', () {
    final g = generator(6);
    final sheet = g.generateAll(g.blank('fantasy'));
    final text = SheetExport.text(sheet, tables.labels, tables.steps);
    for (var i = 0; i < tables.steps.length; i++) {
      expect(text, contains('${i + 1}. ${tables.steps[i]}'));
    }
    expect(text, contains('- Qualités : '));
    expect(jsonDecode(SheetExport.jsonText(sheet)), sheet.toJson());
  });

  test('chronicles cards enrich the pools and seed an imported sheet', () {
    final data = sampleData();
    final rich = tables.withChronicles(data);
    expect(
      rich.pool('fantasy', 'job').length,
      greaterThan(tables.pool('fantasy', 'job').length),
    );
    final g = generator(8, rich);
    final kept = [
      for (final c in data.cards)
        if (c.type == 'metier' && c.universe == 'fantasy') KeptCard(c),
    ].take(1).toList();
    final sheet = SheetImport.fromKept(g, 'fantasy', kept);
    expect(sheet.first('job'), kept.single.card.name);
    expect(sheet.isLocked('job'), isTrue);
    expect(sheet.completedSteps, SheetSpec.stepCount);
    expect(SheetChecks.problems(sheet, rich), isEmpty);
  });

  test('the use case builds a generator from the bundled tables', () async {
    final bundle = _FileBundle();
    final useCase = LoadSheetGeneratorUseCase(
      SheetTablesGatewayImpl(ChroniclesCatalogGatewayImpl(bundle), bundle),
    );
    final g = await useCase(random: RandomTools(random: Random(1)));
    final sheet = g.generateAll(g.blank('gothique'));
    expect(sheet.completedSteps, SheetSpec.stepCount);
  });
}
