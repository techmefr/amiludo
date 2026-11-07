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
    List<String> list(String key) => [
      for (final v in j[key] as List) v as String,
    ];
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
