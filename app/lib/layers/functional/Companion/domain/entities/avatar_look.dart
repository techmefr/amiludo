class AvatarPick {
  const AvatarPick(this.itemId, [this.color]);

  factory AvatarPick.fromJson(Map<String, dynamic> j) =>
      AvatarPick(j['item'] as String, (j['color'] as num?)?.toInt());

  final String itemId;
  final int? color;

  Map<String, dynamic> toJson() => {
    'item': itemId,
    if (color != null) 'color': color,
  };
}

class AvatarLook {
  const AvatarLook([this.picks = const {}]);

  factory AvatarLook.fromJson(Map<String, dynamic>? j) => AvatarLook({
    for (final e in (j ?? const <String, dynamic>{}).entries)
      e.key: AvatarPick.fromJson(Map<String, dynamic>.from(e.value as Map)),
  });

  final Map<String, AvatarPick> picks;

  bool get isEmpty => picks.isEmpty;

  AvatarLook withPick(String slot, AvatarPick? pick) {
    final next = Map<String, AvatarPick>.from(picks);
    if (pick == null) {
      next.remove(slot);
    } else {
      next[slot] = pick;
    }
    return AvatarLook(next);
  }

  Map<String, dynamic> toJson() => {
    for (final e in picks.entries) e.key: e.value.toJson(),
  };
}
