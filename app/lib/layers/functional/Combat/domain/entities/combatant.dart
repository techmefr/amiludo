const combatConditions = [
  'blinded',
  'charmed',
  'frightened',
  'hidden',
  'paralyzed',
  'poisoned',
  'prone',
  'stunned',
];

String newCombatId() => DateTime.now().microsecondsSinceEpoch.toString();

class Combatant {
  const Combatant({
    required this.id,
    required this.name,
    this.initiative,
    this.bonus = 0,
    this.hp = 0,
    this.maxHp = 0,
    this.conditions = const [],
    this.player = false,
  });

  factory Combatant.fromJson(Map<String, dynamic> j) => Combatant(
    id: j['id'] as String? ?? newCombatId(),
    name: j['name'] as String? ?? '',
    initiative: j['initiative'] as int?,
    bonus: j['bonus'] as int? ?? 0,
    hp: j['hp'] as int? ?? 0,
    maxHp: j['maxHp'] as int? ?? 0,
    conditions: [
      for (final c in j['conditions'] as List? ?? const [])
        if (combatConditions.contains(c)) c as String,
    ],
    player: j['player'] == true,
  );

  final String id, name;
  final int? initiative;
  final int bonus, hp, maxHp;
  final List<String> conditions;
  final bool player;

  bool get tracksHp => maxHp > 0;

  bool get down => !player && tracksHp && hp <= 0;

  double get health => tracksHp ? (hp / maxHp).clamp(0, 1).toDouble() : 1;

  Combatant copyWith({
    String? name,
    int? initiative,
    int? bonus,
    int? hp,
    int? maxHp,
    List<String>? conditions,
    bool? player,
  }) => Combatant(
    id: id,
    name: name ?? this.name,
    initiative: initiative ?? this.initiative,
    bonus: bonus ?? this.bonus,
    hp: hp ?? this.hp,
    maxHp: maxHp ?? this.maxHp,
    conditions: conditions ?? this.conditions,
    player: player ?? this.player,
  );

  Combatant hit(int delta) =>
      copyWith(hp: tracksHp ? (hp + delta).clamp(0, maxHp) : hp);

  Combatant toggled(String condition) => copyWith(
    conditions: conditions.contains(condition)
        ? [
            for (final c in conditions)
              if (c != condition) c,
          ]
        : [...conditions, condition],
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'initiative': initiative,
    'bonus': bonus,
    'hp': hp,
    'maxHp': maxHp,
    'conditions': conditions,
    'player': player,
  };
}
