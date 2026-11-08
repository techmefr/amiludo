import 'dart:math';

import 'package:amiludo/layers/functional/World/domain/entities/map_element.dart';

enum ScaleLevel { world, region, city, building, room }

extension ScaleLevelCell on ScaleLevel {
  double get cellMeters => switch (this) {
    ScaleLevel.world => 100000,
    ScaleLevel.region => 10000,
    ScaleLevel.city => 100,
    ScaleLevel.building => 5,
    ScaleLevel.room => 1,
  };

  String get cellLabel {
    final meters = cellMeters;
    return meters >= 1000 ? '${meters ~/ 1000} km' : '${meters.round()} m';
  }
}

const gridCell = 50.0;

String newWorldId() => DateTime.now().microsecondsSinceEpoch.toString();

class MapFloor {
  const MapFloor({
    required this.id,
    required this.name,
    this.elements = const [],
  });

  factory MapFloor.fromJson(Map<String, dynamic> j) => MapFloor(
    id: j['id'] as String? ?? newWorldId(),
    name: j['name'] as String? ?? '',
    elements: [
      for (final e in j['elements'] as List? ?? const [])
        MapElement.fromJson(Map<String, dynamic>.from(e as Map)),
    ],
  );

  final String id, name;
  final List<MapElement> elements;

  MapFloor copyWith({String? name, List<MapElement>? elements}) => MapFloor(
    id: id,
    name: name ?? this.name,
    elements: elements ?? this.elements,
  );

  MapElement? nearest(WorldPoint p, double tolerance) {
    MapElement? best;
    var bestDistance = tolerance;
    for (final e in elements.reversed) {
      final d = e.distanceTo(p);
      if (d <= bestDistance) {
        best = e;
        bestDistance = d;
      }
    }
    return best;
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'elements': [for (final e in elements) e.toJson()],
  };
}

class WorldMap {
  const WorldMap({
    required this.id,
    required this.name,
    this.level = ScaleLevel.region,
    this.floors = const [],
    this.grid = false,
    this.parentId,
  });

  factory WorldMap.create(String name, ScaleLevel level, {String? parentId}) =>
      WorldMap(
        id: newWorldId(),
        name: name,
        level: level,
        floors: [MapFloor(id: '${newWorldId()}f', name: '0')],
        parentId: parentId,
      );

  factory WorldMap.fromJson(Map<String, dynamic> j) {
    final floors = [
      for (final f in j['floors'] as List? ?? const [])
        MapFloor.fromJson(Map<String, dynamic>.from(f as Map)),
    ];
    return WorldMap(
      id: j['id'] as String? ?? newWorldId(),
      name: j['name'] as String? ?? '',
      level: ScaleLevel.values.firstWhere(
        (l) => l.name == j['level'],
        orElse: () => ScaleLevel.region,
      ),
      floors: floors.isEmpty ? [MapFloor(id: '${newWorldId()}f', name: '0')] : floors,
      grid: j['grid'] == true,
      parentId: j['parentId'] as String?,
    );
  }

  final String id, name;
  final ScaleLevel level;
  final List<MapFloor> floors;
  final bool grid;
  final String? parentId;

  MapFloor? floor(String id) => floors.where((f) => f.id == id).firstOrNull;

  MapFloor? below(String id) {
    final at = floors.indexWhere((f) => f.id == id);
    return at > 0 ? floors[at - 1] : null;
  }

  WorldMap copyWith({
    String? name,
    ScaleLevel? level,
    List<MapFloor>? floors,
    bool? grid,
  }) => WorldMap(
    id: id,
    name: name ?? this.name,
    level: level ?? this.level,
    floors: floors ?? this.floors,
    grid: grid ?? this.grid,
    parentId: parentId,
  );

  WorldMap _onFloor(String floorId, MapFloor Function(MapFloor) change) =>
      copyWith(
        floors: [for (final f in floors) f.id == floorId ? change(f) : f],
      );

  String nextFloorName({bool below = false}) {
    final numbers = [
      for (final f in floors)
        if (int.tryParse(f.name) != null) int.parse(f.name),
    ];
    if (numbers.isEmpty) return '${floors.length}';
    return below
        ? '${numbers.reduce(min) - 1}'
        : '${numbers.reduce(max) + 1}';
  }

  WorldMap addFloor(String name, {bool below = false}) {
    final floor = MapFloor(id: '${newWorldId()}f', name: name);
    return copyWith(floors: below ? [floor, ...floors] : [...floors, floor]);
  }

  WorldMap renameFloor(String floorId, String name) =>
      _onFloor(floorId, (f) => f.copyWith(name: name));

  WorldMap removeFloor(String floorId) {
    if (floors.length < 2) return this;
    return copyWith(
      floors: [
        for (final f in floors)
          if (f.id != floorId)
            f.copyWith(
              elements: [
                for (final e in f.elements)
                  if (e.target != floorId) e,
              ],
            ),
      ],
    );
  }

  WorldMap addElement(String floorId, MapElement element) {
    final at = floors.indexWhere((f) => f.id == floorId);
    if (at < 0) return this;
    var next = element;
    MapFloor? partner;
    if (element.kind == ElementKind.stairs) {
      partner = at + 1 < floors.length ? floors[at + 1] : below(floorId);
      if (partner != null) {
        next = MapElement(
          id: element.id,
          kind: element.kind,
          points: element.points,
          target: partner.id,
        );
      }
    }
    var result = _onFloor(
      floorId,
      (f) => f.copyWith(elements: [...f.elements, next]),
    );
    if (partner != null) {
      result = result._onFloor(
        partner.id,
        (f) => f.copyWith(
          elements: [
            ...f.elements,
            MapElement(
              id: '${element.id}p',
              kind: ElementKind.stairs,
              points: element.points,
              target: floorId,
            ),
          ],
        ),
      );
    }
    return result;
  }

  WorldMap removeElement(String elementId) {
    final base = elementId.endsWith('p')
        ? elementId.substring(0, elementId.length - 1)
        : elementId;
    final gone = {base, '${base}p'};
    return copyWith(
      floors: [
        for (final f in floors)
          f.copyWith(
            elements: [
              for (final e in f.elements)
                if (!gone.contains(e.id)) e,
            ],
          ),
      ],
    );
  }

  WorldMap undo(String floorId) {
    final last = floor(floorId)?.elements.lastOrNull;
    return last == null ? this : removeElement(last.id);
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'level': level.name,
    'floors': [for (final f in floors) f.toJson()],
    'grid': grid,
    'parentId': parentId,
  };
}
