import 'dart:math';

enum ElementKind {
  land,
  water,
  forest,
  mountain,
  road,
  river,
  wall,
  room,
  door,
  stairs,
}

extension ElementKindShape on ElementKind {
  bool get isBrush => const {
    ElementKind.land,
    ElementKind.water,
    ElementKind.forest,
    ElementKind.mountain,
  }.contains(this);

  bool get isPath => const {
    ElementKind.road,
    ElementKind.river,
    ElementKind.wall,
  }.contains(this);

  bool get isSymbol => this == ElementKind.door || this == ElementKind.stairs;
}

const defaultBrushWidth = 44.0;

String newElementId() => DateTime.now().microsecondsSinceEpoch.toString();

class WorldPoint {
  const WorldPoint(this.x, this.y);

  factory WorldPoint.fromJson(Object? j) {
    final list = j is List ? j : const [];
    return WorldPoint(
      list.isNotEmpty ? (list[0] as num).toDouble() : 0,
      list.length > 1 ? (list[1] as num).toDouble() : 0,
    );
  }

  final double x, y;

  double distanceTo(WorldPoint other) =>
      sqrt(pow(x - other.x, 2) + pow(y - other.y, 2));

  List<double> toJson() => [x, y];
}

double _segmentDistance(WorldPoint p, WorldPoint a, WorldPoint b) {
  final dx = b.x - a.x, dy = b.y - a.y;
  final length = dx * dx + dy * dy;
  if (length == 0) return p.distanceTo(a);
  final t = (((p.x - a.x) * dx + (p.y - a.y) * dy) / length).clamp(0.0, 1.0);
  return p.distanceTo(WorldPoint(a.x + t * dx, a.y + t * dy));
}

class MapElement {
  const MapElement({
    required this.id,
    required this.kind,
    required this.points,
    this.width = defaultBrushWidth,
    this.target,
  });

  factory MapElement.fromJson(Map<String, dynamic> j) => MapElement(
    id: j['id'] as String? ?? newElementId(),
    kind: ElementKind.values.firstWhere(
      (k) => k.name == j['kind'],
      orElse: () => ElementKind.land,
    ),
    points: [
      for (final p in j['points'] as List? ?? const []) WorldPoint.fromJson(p),
    ],
    width: (j['width'] as num?)?.toDouble() ?? defaultBrushWidth,
    target: j['target'] as String?,
  );

  final String id;
  final ElementKind kind;
  final List<WorldPoint> points;
  final double width;
  final String? target;

  double distanceTo(WorldPoint p) {
    if (points.isEmpty) return double.infinity;
    if (kind.isSymbol || points.length == 1) {
      return p.distanceTo(points.first) - (kind.isBrush ? width / 2 : 0);
    }
    if (kind == ElementKind.room) {
      final a = points.first, b = points.last;
      final left = min(a.x, b.x), right = max(a.x, b.x);
      final top = min(a.y, b.y), bottom = max(a.y, b.y);
      final inside = p.x >= left && p.x <= right && p.y >= top && p.y <= bottom;
      if (inside) return 0;
      final dx = max(max(left - p.x, 0), p.x - right).toDouble();
      final dy = max(max(top - p.y, 0), p.y - bottom).toDouble();
      return sqrt(dx * dx + dy * dy);
    }
    var best = double.infinity;
    for (var i = 1; i < points.length; i++) {
      best = min(best, _segmentDistance(p, points[i - 1], points[i]));
    }
    return best - (kind.isBrush ? width / 2 : 0);
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind.name,
    'points': [for (final p in points) p.toJson()],
    'width': width,
    'target': target,
  };
}
