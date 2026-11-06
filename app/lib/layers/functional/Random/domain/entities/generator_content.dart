import 'dart:convert';

import 'package:amiludo/layers/functional/Random/domain/entities/generator_recipes.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';

class GeneratedSection {
  const GeneratedSection(this.label, this.lines);
  final String label;
  final List<String> lines;
}

class GeneratedSheet {
  const GeneratedSheet(this.title, this.sections);
  final String title;
  final List<GeneratedSection> sections;

  String toText() => [
    title,
    for (final s in sections) '\n${s.label}\n${s.lines.join('\n')}',
  ].join('\n');
}

class GeneratorTables {
  GeneratorTables(this._data);
  factory GeneratorTables.decode(String source) =>
      GeneratorTables(jsonDecode(source) as Map<String, dynamic>);

  final Map<String, dynamic> _data;

  List<String> list(String group, String key) =>
      List<String>.from((_data[group] as Map)[key] as List);

  String label(String key) => (_data['labels'] as Map)[key] as String;
}

class GeneratorEngine {
  GeneratorEngine(this.tables, {RandomTools? random})
    : _random = random ?? RandomTools();
  final GeneratorTables tables;
  final RandomTools _random;

  String _pick(String group, String key) {
    final values = tables.list(group, key);
    return values[_random.integer(0, values.length - 1)];
  }

  List<String> _pickMany(String group, String key, int count) {
    final values = _random.shuffled(tables.list(group, key));
    return values.take(count).toList();
  }

  GeneratedSheet npc() {
    final name = '${_pick('npc', 'firstNames')} ${_pick('npc', 'lastNames')}';
    return GeneratedSheet(name, [
      GeneratedSection(tables.label('description'), [
        '${_pick('npc', 'peoples')} · ${_pick('npc', 'jobs')} · ${_pick('npc', 'ages')}',
        _pick('npc', 'builds'),
        _pick('npc', 'hair'),
        _pick('npc', 'eyes'),
        _pick('npc', 'marks'),
      ]),
      GeneratedSection(tables.label('traits'), _pickMany('npc', 'traits', 3)),
      GeneratedSection(tables.label('secret'), [_pick('npc', 'secrets')]),
      GeneratedSection(tables.label('hook'), [_pick('npc', 'hooks')]),
    ]);
  }

  GeneratedSheet tavern() => GeneratedSheet(
    '${_pick('tavern', 'nouns')} ${_pick('tavern', 'adjectives')}',
    [
      GeneratedSection(tables.label('menu'), [
        ..._pickMany('tavern', 'dishes', 3),
        ..._pickMany('tavern', 'drinks', 2),
      ]),
      GeneratedSection(
        tables.label('rumours'),
        _pickMany('tavern', 'rumours', 2),
      ),
      GeneratedSection(tables.label('staff'), _pickMany('tavern', 'staff', 2)),
    ],
  );

  GeneratedSheet encounter() => GeneratedSheet(_pick('encounter', 'places'), [
    GeneratedSection(tables.label('core'), [_pick('encounter', 'cores')]),
    GeneratedSection(
      tables.label('complications'),
      _pickMany('encounter', 'complications', 2),
    ),
    GeneratedSection(tables.label('twist'), [_pick('encounter', 'twists')]),
  ]);

  GeneratedSheet quest() => GeneratedSheet(_pick('quest', 'goals'), [
    GeneratedSection(tables.label('giver'), [_pick('quest', 'givers')]),
    GeneratedSection(tables.label('location'), [_pick('quest', 'locations')]),
    GeneratedSection(tables.label('obstacle'), [_pick('quest', 'obstacles')]),
    GeneratedSection(tables.label('stakes'), [_pick('quest', 'stakes')]),
    GeneratedSection(tables.label('reward'), [_pick('quest', 'rewards')]),
  ]);

  GeneratedSheet treasure() => GeneratedSheet(_pick('treasure', 'containers'), [
    GeneratedSection(tables.label('loot'), _pickMany('treasure', 'loot', 3)),
    GeneratedSection(tables.label('curio'), [_pick('treasure', 'curios')]),
  ]);

  GeneratedSheet villain() => GeneratedSheet(
    '${_pick('villain', 'firstNames')} ${_pick('villain', 'epithets')}',
    [
      GeneratedSection(tables.label('motive'), [_pick('villain', 'motives')]),
      GeneratedSection(tables.label('method'), [_pick('villain', 'methods')]),
      GeneratedSection(tables.label('weakness'), [
        _pick('villain', 'weaknesses'),
      ]),
      GeneratedSection(tables.label('lair'), [_pick('villain', 'lairs')]),
    ],
  );

  GeneratedSheet town() => GeneratedSheet(
    '${_pick('town', 'starts')}${_pick('town', 'ends')}',
    [
      GeneratedSection(tables.label('size'), [_pick('town', 'sizes')]),
      GeneratedSection(tables.label('trade'), [_pick('town', 'trades')]),
      GeneratedSection(tables.label('landmark'), [_pick('town', 'landmarks')]),
      GeneratedSection(tables.label('problem'), [_pick('town', 'problems')]),
      GeneratedSection(tables.label('custom'), [_pick('town', 'customs')]),
    ],
  );

  GeneratedSheet fromRecipe(GeneratorRecipe r) => GeneratedSheet(
    r.titleKeys.map((k) => _pick(r.group, k)).join(r.separator),
    [
      for (final s in r.sections)
        GeneratedSection(
          tables.label(s.label),
          _pickMany(r.group, s.key, s.count),
        ),
    ],
  );

  GeneratedSheet generate(String id) => switch (id) {
    'npc' => npc(),
    'tavern' => tavern(),
    'encounter' => encounter(),
    'quest' => quest(),
    'treasure' => treasure(),
    'villain' => villain(),
    'town' => town(),
    _ when generatorRecipes.containsKey(id) => fromRecipe(
      generatorRecipes[id]!,
    ),
    _ => throw ArgumentError.value(id, 'id', 'Unknown generator'),
  };
}
