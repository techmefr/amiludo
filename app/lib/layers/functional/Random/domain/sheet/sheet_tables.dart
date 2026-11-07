import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_fields.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_universe.dart';

export 'package:amiludo/layers/functional/Random/domain/sheet/sheet_universe.dart';

const _chroniclesFields = {
  'surnom': 'nickname',
  'genre': 'gender',
  'metier': 'job',
  'statut': 'status',
  'groupe': 'group',
  'style': 'style',
  'signe': 'marks',
  'qualite': 'qualities',
  'defaut': 'flaws',
  'aime': 'likes',
  'deteste': 'dislikes',
  'talent': 'talents',
  'habitude': 'habits',
  'motivation': 'motivation',
  'but': 'goal',
  'famille': 'family',
  'enfance': 'childhood',
  'experience': 'experiences',
  'evolution': 'evolution',
  'situation': 'situation',
  'action': 'aims',
  'quete': 'aims',
};

const editionFields = [
  'job',
  'talents',
  'qualities',
  'habits',
  'style',
  'motivation',
  'goal',
  'group',
];

class SheetTables {
  const SheetTables({
    required this.universes,
    required this.common,
    required this.opposites,
    required this.steps,
    required this.labels,
    this.palettes = const {},
    this.editions = const {},
  });

  factory SheetTables.fromJson(Map<String, dynamic> j) => SheetTables(
    universes: {
      for (final e in (j['univers'] as Map).entries)
        e.key as String: SheetUniverse.fromJson(
          e.key as String,
          Map<String, dynamic>.from(e.value as Map),
        ),
    },
    common: poolsFrom(j['commun'] as Map),
    opposites: [
      for (final p in j['contraires'] as List)
        [for (final t in p as List) t as String],
    ],
    steps: [for (final s in j['etapes'] as List) s as String],
    labels: (j['libelles'] as Map).map((k, v) => MapEntry('$k', '$v')),
    editions: {
      for (final e in (j['editions'] as Map? ?? const {}).entries)
        e.key as String: poolsFrom(e.value as Map),
    },
  );

  final Map<String, SheetUniverse> universes;
  final Map<String, List<SheetOption>> common;
  final List<List<String>> opposites;
  final List<String> steps;
  final Map<String, String> labels;
  final Map<String, List<String>> palettes;
  final Map<String, Map<String, List<SheetOption>>> editions;

  SheetUniverse universe(String id) =>
      universes[id] ?? (throw ArgumentError('Univers inconnu : $id'));

  List<SheetOption> pool(String universeId, String field) => [
    ...?universe(universeId).pools[field],
    ...?common[field],
  ];

  List<SheetOption> editionPool(String? edition, String field) =>
      edition == null ? const [] : (editions[edition]?[field] ?? const []);

  Set<String> oppositesOf(Iterable<String> texts) => {
    for (final p in opposites)
      if (texts.contains(p[0])) p[1] else if (texts.contains(p[1])) p[0],
  };

  SheetTables withChronicles(ChroniclesData data) {
    final merged = <String, SheetUniverse>{};
    for (final u in universes.values) {
      final pools = {
        for (final e in u.pools.entries) e.key: [...e.value],
      };
      for (final c in data.cards) {
        final field = _chroniclesFields[c.type];
        if (field == null || (c.universe != u.id && c.universe != '*')) {
          continue;
        }
        final list = pools.putIfAbsent(field, () => []);
        if (!list.any((o) => o.text == c.name)) list.add(SheetOption(c.name));
      }
      merged[u.id] = SheetUniverse(u.id, u.era, u.cultures, pools);
    }
    return SheetTables(
      universes: merged,
      common: common,
      opposites: opposites,
      steps: steps,
      labels: labels,
      palettes: palettes,
      editions: editions,
    );
  }

  SheetTables withPalettes(Map<String, List<String>> next) => SheetTables(
    universes: universes,
    common: common,
    opposites: opposites,
    steps: steps,
    labels: labels,
    palettes: next,
    editions: editions,
  );

  String? colorOf(String palette, int index) {
    final colors = palettes[palette];
    return colors != null && index >= 0 && index < colors.length
        ? colors[index]
        : null;
  }

  List<String> problems({int minimum = 4}) {
    final found = <String>[];
    final universal = {
      'name',
      'age',
      'birthDate',
      'birthPlace',
      'origin',
      'languages',
    };
    for (final u in universes.values) {
      if (u.cultures.isEmpty) found.add('${u.id}: no culture');
      for (final f in SheetSpec.fields) {
        if (universal.contains(f.id)) continue;
        final n = pool(u.id, f.id).length;
        if (n < minimum || n < f.min) found.add('${u.id}.${f.id}: $n options');
      }
    }
    for (final e in editions.entries) {
      for (final f in editionFields) {
        if ((e.value[f]?.length ?? 0) < 3) found.add('${e.key}.$f: too few');
      }
    }
    for (final f in SheetSpec.fields) {
      if (!labels.containsKey(f.id)) found.add('${f.id}: no label');
    }
    return found;
  }
}
