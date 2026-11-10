import 'dart:convert';
import 'dart:ui';

class RigPlacement {
  const RigPlacement({
    this.rect,
    this.pair = false,
    this.z,
    this.hidden = false,
  });

  factory RigPlacement.fromJson(Map<String, dynamic> j) {
    final r = (j['rect'] as List?)?.map((v) => (v as num).toDouble()).toList();
    return RigPlacement(
      rect: r == null ? null : Rect.fromLTWH(r[0], r[1], r[2], r[3]),
      pair: j['pair'] as bool? ?? false,
      z: (j['z'] as num?)?.toInt(),
      hidden: j['hidden'] as bool? ?? false,
    );
  }

  final Rect? rect;
  final bool pair;
  final int? z;
  final bool hidden;
}

class AvatarRig {
  const AvatarRig({
    this.kinds = const {},
    this.hides = const {},
    this.defaults = const [],
    this.optional = const {},
    this.slotOrder = const [],
  });

  factory AvatarRig.decode(String source) {
    final j = jsonDecode(source) as Map<String, dynamic>;
    List<String> strings(Object? v) => [
      for (final s in (v as List? ?? const [])) s as String,
    ];
    return AvatarRig(
      kinds: {
        for (final e in (j['kinds'] as Map? ?? const {}).entries)
          e.key as String: RigPlacement.fromJson(
            Map<String, dynamic>.from(e.value as Map),
          ),
      },
      hides: {
        for (final e in (j['hides'] as Map? ?? const {}).entries)
          e.key as String: strings(e.value),
      },
      defaults: strings(j['defaults']),
      optional: strings(j['optional']).toSet(),
      slotOrder: strings(j['slotOrder']),
    );
  }

  final Map<String, RigPlacement> kinds;
  final Map<String, List<String>> hides;
  final List<String> defaults;
  final Set<String> optional;
  final List<String> slotOrder;

  static String kindOf(String id) => id.replaceAll(RegExp(r'(-\d+)+$'), '');

  RigPlacement? placementOf(String id) {
    final kind = kindOf(id);
    return kinds[kind] ?? kinds[kind.split('.').first];
  }

  bool isHidden(String id) => placementOf(id)?.hidden ?? false;

  Set<String> hiddenSlots(Iterable<String> ids) => {
    for (final id in ids) ...?hides[kindOf(id)],
  };
}
