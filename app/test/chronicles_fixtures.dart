import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_draw.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_run.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';

const rarityIds = ['c', 'u', 'r', 'e', 'l', 'm'];

Map<String, dynamic> sampleJson() => jsonDecode(
  File('assets/chronicles/chronicles-data.json').readAsStringSync(),
) as Map<String, dynamic>;

ChroniclesData sampleData() => ChroniclesData.fromJson(sampleJson());

RandomTools seeded(int seed) => RandomTools(random: Random(seed));

Map<String, dynamic> _card(String type, String rarity, int i) => {
  'id': '$type-$rarity-$i',
  'univers': 'u',
  'etape': 1,
  'type': type,
  'libelle': null,
  'rarete': rarity,
  'nom': '$type $rarity $i',
  'texte': 'text',
  'modificateurs': <String, int>{},
  'tags': <String>[],
  'conflits': <String>[],
  'apparence': null,
  'epithete': null,
};

ChroniclesData syntheticData() {
  final types = [for (var t = 0; t < 12; t++) 't$t'];
  return ChroniclesData.fromJson({
    'caracteristiques': [
      for (final s in ['for', 'agi', 'int', 'cha', 'vol', 'per'])
        {'id': s, 'nom': s},
    ],
    'raretes': [
      for (final (i, w) in [45, 27, 15, 8, 4, 1].indexed)
        {'id': rarityIds[i], 'nom': rarityIds[i], 'poids': w, 'score': i + 1},
    ],
    'etapes': [
      {
        'id': 1,
        'nom': 'one',
        'types': [
          for (final t in types) {'type': t, 'min': 1, 'max': 1},
        ],
      },
    ],
    'editions': [
      {
        'id': 'fer',
        'nom': 'Fer',
        'stats': ['for', 'vol'],
      },
    ],
    'univers': [
      {'id': 'u', 'nom': 'U', 'epithete': 'Default'},
    ],
    'libellesCourts': <String, String>{},
    'cartes': [
      for (final t in types)
        for (final r in rarityIds)
          for (var i = 0; i < 3; i++) _card(t, r, i),
    ],
  });
}

ChroniclesRun playThrough(
  ChroniclesData data,
  RandomTools random, {
  String universe = 'fantasy',
}) {
  final run = ChroniclesRun(universe)..next(data);
  final draw = ChroniclesDraw(data, random);
  var guard = 0;
  while (run.phase != ChroniclesPhase.done && guard++ < 1000) {
    switch (run.phase) {
      case ChroniclesPhase.edition:
        run.openBooster(data, draw, 'fer');
      case ChroniclesPhase.discover:
        if (run.keep(data) != null) run.pass();
      case ChroniclesPhase.recap:
        run.next(data);
      case ChroniclesPhase.done:
        break;
    }
  }
  return run;
}
