import 'package:amiludo/layers/functional/World/domain/entities/map_element.dart';
import 'package:amiludo/layers/functional/World/domain/entities/map_pin.dart';

class MapFloor {
  const MapFloor({
    required this.id,
    required this.name,
    this.elements = const [],
    this.pins = const [],
  });

  factory MapFloor.fromJson(Map<String, dynamic> j) => MapFloor(
    id: j['id'] as String? ?? newElementId(),
    name: j['name'] as String? ?? '',
    elements: [
      for (final e in j['elements'] as List? ?? const [])
        MapElement.fromJson(Map<String, dynamic>.from(e as Map)),
    ],
    pins: [
      for (final p in j['pins'] as List? ?? const [])
        MapPin.fromJson(Map<String, dynamic>.from(p as Map)),
    ],
  );

  final String id, name;
  final List<MapElement> elements;
  final List<MapPin> pins;

  MapFloor copyWith({
    String? name,
    List<MapElement>? elements,
    List<MapPin>? pins,
  }) => MapFloor(
    id: id,
    name: name ?? this.name,
    elements: elements ?? this.elements,
    pins: pins ?? this.pins,
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
    'pins': [for (final p in pins) p.toJson()],
  };
}

