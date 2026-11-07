import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_fields.dart';

class SheetOption {
  const SheetOption(this.text, {this.palette, this.kind});

  factory SheetOption.fromJson(Object json) => json is String
      ? SheetOption(json)
      : SheetOption(
          (json as Map)['t'] as String,
          palette: json['p'] as int?,
          kind: json['k'] as String?,
        );

  final String text;
  final int? palette;
  final String? kind;
}

class SheetCulture {
  const SheetCulture({
    required this.id,
    required this.name,
    required this.firstNames,
    required this.lastNames,
    required this.languages,
    required this.places,
  });

  factory SheetCulture.fromJson(Map<String, dynamic> j) {
    List<String> list(String key) =>
        [for (final v in j[key] as List) v as String];
    return SheetCulture(
      id: j['id'] as String,
      name: j['nom'] as String,
      firstNames: list('prenoms'),
      lastNames: list('noms'),
      languages: list('langues'),
      places: list('lieux'),
    );
  }

  final String id, name;
  final List<String> firstNames, lastNames, languages, places;
}

class SheetEra {
  const SheetEra(this.year, this.month, this.day);
  final int year, month, day;
}

class SheetUniverse {
  const SheetUniverse(this.id, this.era, this.cultures, this.pools);

  factory SheetUniverse.fromJson(String id, Map<String, dynamic> j) {
    final era = Map<String, dynamic>.from(j['epoque'] as Map);
    return SheetUniverse(
      id,
      SheetEra(era['annee'] as int, era['mois'] as int, era['jour'] as int),
      [
        for (final c in j['cultures'] as List)
          SheetCulture.fromJson(Map<String, dynamic>.from(c as Map)),
      ],
      poolsFrom(j['champs'] as Map),
    );
  }

  final String id;
  final SheetEra era;
  final List<SheetCulture> cultures;
  final Map<String, List<SheetOption>> pools;

  SheetCulture? culture(String? cultureId) =>
      cultures.where((c) => c.id == cultureId).firstOrNull;

  SheetCulture? cultureNamed(String name) =>
      cultures.where((c) => c.name == name).firstOrNull;
}

Map<String, List<SheetOption>> poolsFrom(Map raw) => {
  for (final e in raw.entries)
    e.key as String: [
      for (final o in e.value as List) SheetOption.fromJson(o as Object),
    ],
};

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

class SheetTables {
  const SheetTables({
    required this.universes,
    required this.common,
    required this.opposites,
    required this.steps,
    required this.labels,
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
  );

  final Map<String, SheetUniverse> universes;
  final Map<String, List<SheetOption>> common;
  final List<List<String>> opposites;
  final List<String> steps;
  final Map<String, String> labels;

  SheetUniverse universe(String id) =>
      universes[id] ?? (throw ArgumentError('Univers inconnu : $id'));

  List<SheetOption> pool(String universeId, String field) => [
    ...?universe(universeId).pools[field],
    ...?common[field],
  ];

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
        if (field == null || (c.universe != u.id && c.universe != '*')) continue;
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
    );
  }

  List<String> problems({int minimum = 4}) {
    final found = <String>[];
    final universal = {'name', 'age', 'birthDate', 'birthPlace', 'origin', 'languages'};
    for (final u in universes.values) {
      if (u.cultures.isEmpty) found.add('${u.id}: no culture');
      for (final f in SheetSpec.fields) {
        if (universal.contains(f.id)) continue;
        final n = pool(u.id, f.id).length;
        if (n < minimum || n < f.min) found.add('${u.id}.${f.id}: $n options');
      }
    }
    for (final f in SheetSpec.fields) {
      if (!labels.containsKey(f.id)) found.add('${f.id}: no label');
    }
    return found;
  }
}
