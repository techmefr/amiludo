const _accents = {
  'à': 'a',
  'â': 'a',
  'ä': 'a',
  'á': 'a',
  'ã': 'a',
  'ç': 'c',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ñ': 'n',
  'ó': 'o',
  'ô': 'o',
  'ö': 'o',
  'õ': 'o',
  'ú': 'u',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ß': 's',
};

String foldText(String text) =>
    text.toLowerCase().split('').map((c) => _accents[c] ?? c).join();

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

class RuleDecision {
  const RuleDecision({
    required this.id,
    required this.question,
    required this.ruling,
    required this.at,
  });

  factory RuleDecision.fromJson(Map<String, dynamic> j) => RuleDecision(
    id: j['id'] as String? ?? newRuleId(),
    question: j['question'] as String? ?? '',
    ruling: j['ruling'] as String? ?? '',
    at: DateTime.fromMillisecondsSinceEpoch(j['at'] as int? ?? 0, isUtc: true),
  );

  final String id, question, ruling;
  final DateTime at;

  bool matches(String query) {
    final needle = foldText(query.trim());
    return needle.isEmpty ||
        foldText(question).contains(needle) ||
        foldText(ruling).contains(needle);
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'question': question,
    'ruling': ruling,
    'at': at.millisecondsSinceEpoch,
  };
}

class RuleGame {
  const RuleGame({
    required this.id,
    required this.name,
    this.sections = const [],
    this.decisions = const [],
  });

  factory RuleGame.fromJson(Map<String, dynamic> j) => RuleGame(
    id: j['id'] as String? ?? newRuleId(),
    name: j['name'] as String? ?? '',
    sections: [
      for (final s in j['sections'] as List? ?? const [])
        RuleSection.fromJson(Map<String, dynamic>.from(s as Map)),
    ],
    decisions: [
      for (final d in j['decisions'] as List? ?? const [])
        RuleDecision.fromJson(Map<String, dynamic>.from(d as Map)),
    ],
  );

  final String id, name;
  final List<RuleSection> sections;
  final List<RuleDecision> decisions;

  RuleGame withSections(List<RuleSection> next) =>
      RuleGame(id: id, name: name, sections: next, decisions: decisions);

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

  RuleGame addDecision(String question, String ruling, DateTime at) {
    final q = question.trim(), r = ruling.trim();
    if (q.isEmpty && r.isEmpty) return this;
    final entry = RuleDecision(
      id: '${at.microsecondsSinceEpoch}-${decisions.length}',
      question: q,
      ruling: r,
      at: at.toUtc(),
    );
    return RuleGame(
      id: id,
      name: name,
      sections: sections,
      decisions: [entry, ...decisions],
    );
  }

  RuleGame removeDecision(String decisionId) => RuleGame(
    id: id,
    name: name,
    sections: sections,
    decisions: [
      for (final d in decisions)
        if (d.id != decisionId) d,
    ],
  );

  List<int> search(String query) => [
    for (var i = 0; i < sections.length; i++)
      if (sections[i].matches(query)) i,
  ];

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'sections': [for (final s in sections) s.toJson()],
    'decisions': [for (final d in decisions) d.toJson()],
  };
}

const commonRuleId = 'common';

class RuleBook {
  const RuleBook({this.games = const [], this.common = const []});

  factory RuleBook.fromJson(Map<String, dynamic> j) => RuleBook(
    games: [
      for (final g in j['rules'] as List? ?? const [])
        RuleGame.fromJson(Map<String, dynamic>.from(g as Map)),
    ],
    common: [
      for (final c in j['commonRules'] as List? ?? const [])
        RuleSection.fromJson(Map<String, dynamic>.from(c as Map)),
    ],
  );

  final List<RuleGame> games;
  final List<RuleSection> common;

  bool get isEmpty => games.isEmpty && common.isEmpty;

  RuleGame get commonGame =>
      RuleGame(id: commonRuleId, name: '', sections: common);

  RuleGame? of(String? id) => id == commonRuleId
      ? commonGame
      : games.where((g) => g.id == id).firstOrNull;

  RuleBook put(RuleGame game) {
    if (game.id == commonRuleId) {
      return RuleBook(games: games, common: game.sections);
    }
    final known = games.any((g) => g.id == game.id);
    return RuleBook(
      games: known
          ? [for (final g in games) g.id == game.id ? game : g]
          : [...games, game],
      common: common,
    );
  }

  RuleBook remove(String id) => RuleBook(
    games: [
      for (final g in games)
        if (g.id != id) g,
    ],
    common: common,
  );

  Map<String, Object?> toJson() => {
    'rules': [for (final g in games) g.toJson()],
    'commonRules': [for (final c in common) c.toJson()],
  };
}
