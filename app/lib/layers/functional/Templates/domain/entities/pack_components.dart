class DieFace {
  const DieFace(this.label, this.value);
  final String label;
  final double value;
  Map<String, Object?> toJson() => {'label': label, 'value': value};
  factory DieFace.fromJson(Map<String, dynamic> j) {
    final f = DieFace(j['label'] as String, (j['value'] as num).toDouble());
    if (f.label.trim().isEmpty ||
        f.label.length > 40 ||
        !f.value.isFinite ||
        f.value.abs() > 1000000) {
      throw const FormatException('Face invalide');
    }
    return f;
  }
}

class GameDie {
  const GameDie({
    required this.name,
    required this.faces,
    this.count = 1,
    this.design,
  });
  final String name;
  final List<DieFace> faces;
  final int count;
  final String? design;
  Map<String, Object?> toJson() => {
    'name': name,
    'count': count,
    'faces': faces.map((f) => f.toJson()).toList(),
    if (design != null) 'design': design,
  };
  factory GameDie.fromJson(Map<String, dynamic> j) {
    final d = GameDie(
      name: j['name'] as String,
      count: j['count'] as int,
      faces: (j['faces'] as List)
          .map((f) => DieFace.fromJson(Map<String, dynamic>.from(f as Map)))
          .toList(),
      design: j['design'] as String?,
    );
    if (d.name.trim().isEmpty ||
        d.name.length > 80 ||
        (d.design != null && (d.design!.isEmpty || d.design!.length > 64)) ||
        d.count < 1 ||
        d.count > 32 ||
        d.faces.length < 2 ||
        d.faces.length > 100) {
      throw const FormatException(
        'Dé invalide : 2–100 faces, 1–32 exemplaires',
      );
    }
    return d;
  }
}

class GameRole {
  const GameRole({required this.name, this.description = '', this.count = 1});
  final String name, description;
  final int count;
  Map<String, Object?> toJson() => {
    'name': name,
    'description': description,
    'count': count,
  };
  factory GameRole.fromJson(Map<String, dynamic> j) {
    final v = GameRole(
      name: j['name'] as String,
      description: j['description'] as String? ?? '',
      count: j['count'] as int,
    );
    if (v.name.trim().isEmpty ||
        v.name.length > 80 ||
        v.description.length > 2000 ||
        v.count < 1 ||
        v.count > 32) {
      throw const FormatException('Rôle invalide');
    }
    return v;
  }
}

class ScoreRule {
  const ScoreRule({
    required this.name,
    this.kind = 'linear',
    this.factor = 1,
    this.step = 1,
    this.bonus = 0,
    this.table = const [],
  });
  final String name, kind;
  final double factor, step, bonus;
  final List<double> table;
  String get explanation => switch (kind) {
    'linear' => 'Quantité × $factor, puis $bonus',
    'sets' => '$factor points par lot de $step, puis $bonus',
    'triangular' => 'Progression 1 + 2 + 3… × $factor, puis $bonus',
    'threshold' => '$factor points à partir de $step, puis $bonus',
    'lookup' => 'Barème de 0 à ${table.length - 1}, puis $bonus',
    _ => 'Calcul personnalisé',
  };
  double calculate(double input) {
    if (!input.isFinite || input.abs() > 1000000) {
      throw const FormatException('Quantité invalide');
    }
    if (kind != 'linear' && (input < 0 || input != input.truncateToDouble())) {
      throw const FormatException(
        'Une quantité entière positive ou nulle est requise',
      );
    }
    final value = switch (kind) {
      'linear' => input * factor,
      'sets' => (input / step).floor() * factor,
      'triangular' => input * (input + 1) / 2 * factor,
      'threshold' => input >= step ? factor : 0.0,
      'lookup' =>
        input < table.length
            ? table[input.toInt()]
            : throw const FormatException('Quantité hors du barème'),
      _ => throw const FormatException('Calcul inconnu'),
    };
    final total = value + bonus;
    if (!total.isFinite || total.abs() > 1000000000) {
      throw const FormatException('Résultat hors limites');
    }
    return total;
  }

  Map<String, Object?> toJson() => {
    'name': name,
    'kind': kind,
    'factor': factor,
    'step': step,
    'bonus': bonus,
    'table': table,
  };
  factory ScoreRule.fromJson(Map<String, dynamic> j) {
    final v = ScoreRule(
      name: j['name'] as String,
      kind: j['kind'] as String? ?? 'linear',
      factor: (j['factor'] as num? ?? 1).toDouble(),
      step: (j['step'] as num? ?? 1).toDouble(),
      bonus: (j['bonus'] as num? ?? 0).toDouble(),
      table: (j['table'] as List? ?? [])
          .map((v) => (v as num).toDouble())
          .toList(),
    );
    if (v.name.trim().isEmpty ||
        v.name.length > 40 ||
        ![
          'linear',
          'sets',
          'triangular',
          'threshold',
          'lookup',
        ].contains(v.kind) ||
        !v.factor.isFinite ||
        v.factor.abs() > 1000000 ||
        !v.step.isFinite ||
        v.step <= 0 ||
        v.step > 1000000 ||
        !v.bonus.isFinite ||
        v.bonus.abs() > 1000000 ||
        v.table.length > 101 ||
        v.table.any((n) => !n.isFinite || n.abs() > 1000000) ||
        (v.kind == 'lookup' && v.table.isEmpty)) {
      throw const FormatException('Règle de score invalide');
    }
    return v;
  }
}

bool validRuleUrl(String value) {
  if (value.isEmpty) return true;
  final u = Uri.tryParse(value);
  return u != null &&
      u.scheme == 'https' &&
      u.host.isNotEmpty &&
      u.userInfo.isEmpty &&
      value.length <= 2000;
}
