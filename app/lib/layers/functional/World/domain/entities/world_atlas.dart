import 'dart:convert';

import 'package:amiludo/layers/functional/World/domain/entities/world_map.dart';

const worldExportFormat = 'amiludo-world';

class WorldAtlas {
  const WorldAtlas({this.maps = const []});

  factory WorldAtlas.fromJson(Map<String, dynamic> j) => WorldAtlas(
    maps: [
      for (final m in j['maps'] as List? ?? const [])
        WorldMap.fromJson(Map<String, dynamic>.from(m as Map)),
    ],
  );

  final List<WorldMap> maps;

  bool get isEmpty => maps.isEmpty;

  WorldMap? of(String id) => maps.where((m) => m.id == id).firstOrNull;

  List<WorldMap> childrenOf(String? parentId) => [
    for (final m in maps)
      if (m.parentId == parentId) m,
  ];

  WorldAtlas put(WorldMap next) {
    final known = maps.any((m) => m.id == next.id);
    return WorldAtlas(
      maps: known
          ? [for (final m in maps) m.id == next.id ? next : m]
          : [...maps, next],
    );
  }

  WorldAtlas remove(String id) => WorldAtlas(
    maps: [
      for (final m in maps)
        if (m.id != id)
          m.copyWith(
            floors: [
              for (final f in m.floors)
                f.copyWith(
                  pins: [
                    for (final p in f.pins)
                      p.childMapId == id ? p.copyWith(clearChild: true) : p,
                  ],
                ),
            ],
          ),
    ],
  );

  String export() => const JsonEncoder.withIndent('  ').convert({
    'format': worldExportFormat,
    'maps': [for (final m in maps) m.toJson()],
  });

  ({WorldAtlas merged, int count})? import(String text) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      return null;
    }
    final list = switch (decoded) {
      {'format': worldExportFormat, 'maps': final List items} => items,
      _ => null,
    };
    if (list == null) return null;
    var merged = this;
    var count = 0;
    for (final item in list) {
      if (item is! Map) return null;
      final map = WorldMap.fromJson(Map<String, dynamic>.from(item));
      if (map.name.trim().isEmpty) continue;
      merged = merged.put(map);
      count++;
    }
    return count == 0 ? null : (merged: merged, count: count);
  }

  Map<String, Object?> toJson() => {
    'maps': [for (final m in maps) m.toJson()],
  };
}
