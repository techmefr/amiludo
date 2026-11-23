enum SoundKind { track, effect }

class SoundEntry {
  const SoundEntry({
    required this.id,
    required this.name,
    this.kind = SoundKind.effect,
    this.color = 'primary',
    this.volume = 1,
    this.loop = false,
    this.mimeType = 'audio/mpeg',
    this.bytesLength = 0,
    this.extra = const {},
  });

  factory SoundEntry.fromJson(Map<String, dynamic> j) {
    const known = {
      'id',
      'name',
      'kind',
      'color',
      'volume',
      'loop',
      'mimeType',
      'bytesLength',
    };
    return SoundEntry(
      id: j['id'] as String,
      name: j['name'] as String? ?? '',
      kind: SoundKind.values.asNameMap()[j['kind']] ?? SoundKind.effect,
      color: j['color'] as String? ?? 'primary',
      volume: ((j['volume'] as num?) ?? 1).toDouble().clamp(0.0, 1.0),
      loop: j['loop'] as bool? ?? false,
      mimeType: j['mimeType'] as String? ?? 'audio/mpeg',
      bytesLength: (j['bytesLength'] as num?)?.toInt() ?? 0,
      extra: {
        for (final e in j.entries)
          if (!known.contains(e.key)) e.key: e.value,
      },
    );
  }

  final String id, name, color, mimeType;
  final SoundKind kind;
  final double volume;
  final bool loop;
  final int bytesLength;
  final Map<String, Object?> extra;

  SoundEntry copyWith({
    String? name,
    SoundKind? kind,
    String? color,
    double? volume,
    bool? loop,
    String? mimeType,
    int? bytesLength,
  }) => SoundEntry(
    id: id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    color: color ?? this.color,
    volume: volume ?? this.volume,
    loop: loop ?? this.loop,
    mimeType: mimeType ?? this.mimeType,
    bytesLength: bytesLength ?? this.bytesLength,
    extra: extra,
  );

  Map<String, Object?> toJson() => {
    ...extra,
    'id': id,
    'name': name,
    'kind': kind.name,
    'color': color,
    'volume': volume,
    'loop': loop,
    'mimeType': mimeType,
    'bytesLength': bytesLength,
  };
}
