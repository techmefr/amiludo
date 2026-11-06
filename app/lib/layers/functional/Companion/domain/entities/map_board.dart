const mapWorld = 1000.0;
const mapBrickType = 'map';
const mapPalette = [
  0xFF3D7BD9,
  0xFFD94A4A,
  0xFF2F9E6B,
  0xFFE0A526,
  0xFF8A55C7,
  0xFF2B2B2B,
];
const mapDefaultIcon = 'flag';
const mapMaxStrokePoints = 2000;

enum MapBackground { blank, grid, hex, image }

enum MapMarkerKind { pin, token }

enum MapStrokeKind { line, zone }

int _ids = 0;

String mapItemId() => '${DateTime.now().microsecondsSinceEpoch}-${_ids++}';

double _clamp(num? v) => (v ?? 0).toDouble().clamp(0.0, mapWorld);

class MapPoint {
  const MapPoint(this.x, this.y);

  factory MapPoint.fromJson(List<dynamic> j) =>
      MapPoint(_clamp(j[0] as num), _clamp(j[1] as num));

  final double x, y;

  List<double> toJson() => [x, y];
}

class MapMarker {
  const MapMarker({
    required this.id,
    required this.x,
    required this.y,
    this.kind = MapMarkerKind.pin,
    this.color = 0xFF3D7BD9,
    this.icon = mapDefaultIcon,
    this.label = '',
  });

  factory MapMarker.fromJson(Map<String, dynamic> j) => MapMarker(
    id: j['id'] as String,
    x: _clamp(j['x'] as num?),
    y: _clamp(j['y'] as num?),
    kind: MapMarkerKind.values.firstWhere(
      (k) => k.name == j['kind'],
      orElse: () => MapMarkerKind.pin,
    ),
    color: (j['color'] as num? ?? 0xFF3D7BD9).toInt(),
    icon: j['icon'] as String? ?? mapDefaultIcon,
    label: j['label'] as String? ?? '',
  );

  final String id, icon, label;
  final double x, y;
  final MapMarkerKind kind;
  final int color;

  MapMarker copyWith({
    double? x,
    double? y,
    int? color,
    String? icon,
    String? label,
  }) => MapMarker(
    id: id,
    x: x ?? this.x,
    y: y ?? this.y,
    kind: kind,
    color: color ?? this.color,
    icon: icon ?? this.icon,
    label: label ?? this.label,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'x': x,
    'y': y,
    'kind': kind.name,
    'color': color,
    'icon': icon,
    'label': label,
  };
}

class MapStroke {
  const MapStroke({
    required this.id,
    required this.points,
    this.kind = MapStrokeKind.line,
    this.color = 0xFF3D7BD9,
  });

  factory MapStroke.fromJson(Map<String, dynamic> j) => MapStroke(
    id: j['id'] as String,
    kind: MapStrokeKind.values.firstWhere(
      (k) => k.name == j['kind'],
      orElse: () => MapStrokeKind.line,
    ),
    color: (j['color'] as num? ?? 0xFF3D7BD9).toInt(),
    points: [
      for (final p in (j['points'] as List? ?? const []).take(
        mapMaxStrokePoints,
      ))
        MapPoint.fromJson(p as List),
    ],
  );

  final String id;
  final MapStrokeKind kind;
  final int color;
  final List<MapPoint> points;

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'color': color,
    'points': points.map((p) => p.toJson()).toList(),
  };
}
