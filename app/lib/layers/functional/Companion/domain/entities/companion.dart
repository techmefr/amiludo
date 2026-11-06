const companionFormatVersion = 1;

enum BrickOwnerKind { table, team, player }

class Brick {
  const Brick({
    required this.id,
    required this.type,
    this.settings = const {},
    this.ownerKind = BrickOwnerKind.table,
    this.ownerId,
    this.extra = const {},
  });

  factory Brick.fromJson(Map<String, dynamic> j) {
    const known = {'id', 'type', 'settings', 'ownerKind', 'ownerId'};
    return Brick(
      id: j['id'] as String,
      type: j['type'] as String,
      settings: Map<String, dynamic>.from(j['settings'] as Map? ?? const {}),
      ownerKind: BrickOwnerKind.values.firstWhere(
        (k) => k.name == j['ownerKind'],
        orElse: () => BrickOwnerKind.table,
      ),
      ownerId: j['ownerId'] as String?,
      extra: {
        for (final e in j.entries)
          if (!known.contains(e.key)) e.key: e.value,
      },
    );
  }

  final String id, type;
  final Map<String, dynamic> settings;
  final BrickOwnerKind ownerKind;
  final String? ownerId;
  final Map<String, dynamic> extra;

  Brick copyWith({
    Map<String, dynamic>? settings,
    BrickOwnerKind? ownerKind,
    String? ownerId,
  }) => Brick(
    id: id,
    type: type,
    settings: settings ?? this.settings,
    ownerKind: ownerKind ?? this.ownerKind,
    ownerId: ownerId ?? this.ownerId,
    extra: extra,
  );

  Map<String, dynamic> toJson() => {
    ...extra,
    'id': id,
    'type': type,
    'settings': settings,
    'ownerKind': ownerKind.name,
    if (ownerId != null) 'ownerId': ownerId,
  };
}

class Companion {
  const Companion({
    required this.id,
    required this.name,
    this.version = companionFormatVersion,
    this.bricks = const [],
    this.extra = const {},
  });

  factory Companion.fromJson(Map<String, dynamic> j) {
    const known = {'id', 'name', 'version', 'bricks'};
    final version = (j['version'] as num?)?.toInt() ?? companionFormatVersion;
    return Companion(
      id: j['id'] as String,
      name: j['name'] as String,
      version: version,
      bricks: [
        for (final b in j['bricks'] as List? ?? const [])
          Brick.fromJson(Map<String, dynamic>.from(b as Map)),
      ],
      extra: {
        for (final e in j.entries)
          if (!known.contains(e.key)) e.key: e.value,
      },
    );
  }

  final String id, name;
  final int version;
  final List<Brick> bricks;
  final Map<String, dynamic> extra;

  bool get fromNewerVersion => version > companionFormatVersion;

  Companion withBricks(List<Brick> next) => Companion(
    id: id,
    name: name,
    version: version,
    bricks: next,
    extra: extra,
  );

  Companion add(Brick brick) => withBricks([...bricks, brick]);

  Companion remove(String brickId) =>
      withBricks(bricks.where((b) => b.id != brickId).toList());

  Companion move(int from, int to) {
    final next = [...bricks];
    next.insert(to, next.removeAt(from));
    return withBricks(next);
  }

  Companion replace(Brick brick) =>
      withBricks([for (final b in bricks) b.id == brick.id ? brick : b]);

  Map<String, dynamic> toJson() => {
    ...extra,
    'id': id,
    'name': name,
    'version': version,
    'bricks': bricks.map((b) => b.toJson()).toList(),
  };
}
