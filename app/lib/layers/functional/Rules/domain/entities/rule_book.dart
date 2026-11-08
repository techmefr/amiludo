const _accents = {
  'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a', 'ç': 'c',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', 'í': 'i', 'î': 'i', 'ï': 'i',
  'ñ': 'n', 'ó': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u', 'ß': 's',
};

String foldText(String text) => text
    .toLowerCase()
    .split('')
    .map((c) => _accents[c] ?? c)
    .join();

String newRuleId() => DateTime.now().microsecondsSinceEpoch.toString();

class RuleSection {
  const RuleSection({required this.title, required this.body});

  factory RuleSection.fromJson(Map<String, dynamic> j) => RuleSection(
    title: j['title'] as String? ?? '',
    body: j['body'] as String? ?? '',
  );

  final String title, body;

  bool matches(String query) {
    final needle = foldText(query.trim());
    return needle.isEmpty ||
        foldText(title).contains(needle) ||
        foldText(body).contains(needle);
  }

  Map<String, Object?> toJson() => {'title': title, 'body': body};
}

class RuleGame {
  const RuleGame({
    required this.id,
    required this.name,
    this.sections = const [],
  });

  factory RuleGame.fromJson(Map<String, dynamic> j) => RuleGame(
    id: j['id'] as String? ?? newRuleId(),
    name: j['name'] as String? ?? '',
    sections: [
      for (final s in j['sections'] as List? ?? const [])
        RuleSection.fromJson(Map<String, dynamic>.from(s as Map)),
    ],
  );

  final String id, name;
  final List<RuleSection> sections;

  RuleGame withSections(List<RuleSection> next) =>
      RuleGame(id: id, name: name, sections: next);

  RuleGame withSection(int index, RuleSection section) {
    final next = [...sections];
    if (index >= 0 && index < next.length) {
      next[index] = section;
    } else {
      next.add(section);
    }
    return withSections(next);
  }

  RuleGame withoutSection(int index) => withSections([
    for (var i = 0; i < sections.length; i++)
      if (i != index) sections[i],
  ]);

  List<int> search(String query) => [
    for (var i = 0; i < sections.length; i++)
      if (sections[i].matches(query)) i,
  ];

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'sections': [for (final s in sections) s.toJson()],
  };
}

class RuleBook {
  const RuleBook({this.games = const []});

  factory RuleBook.fromJson(Map<String, dynamic> j) => RuleBook(
    games: [
      for (final g in j['rules'] as List? ?? const [])
        RuleGame.fromJson(Map<String, dynamic>.from(g as Map)),
    ],
  );

  final List<RuleGame> games;

  bool get isEmpty => games.isEmpty;

  RuleGame? of(String? id) => games.where((g) => g.id == id).firstOrNull;

  RuleBook put(RuleGame game) {
    final known = games.any((g) => g.id == game.id);
    return RuleBook(
      games: known
          ? [for (final g in games) g.id == game.id ? game : g]
          : [...games, game],
    );
  }

  RuleBook remove(String id) =>
      RuleBook(games: [for (final g in games) if (g.id != id) g]);

  Map<String, Object?> toJson() => {
    'rules': [for (final g in games) g.toJson()],
  };
}
