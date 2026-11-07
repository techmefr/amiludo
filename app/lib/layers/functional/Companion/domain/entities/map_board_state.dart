import 'package:amiludo/layers/functional/Companion/domain/entities/map_board.dart';

class MapBoard {
  const MapBoard({
    this.background = MapBackground.blank,
    this.imageId,
    this.markers = const [],
    this.strokes = const [],
  });

  factory MapBoard.fromJson(Map<String, dynamic> j) => MapBoard(
    background: MapBackground.values.firstWhere(
      (b) => b.name == j['background'],
      orElse: () => MapBackground.blank,
    ),
    imageId: j['imageId'] as String?,
    markers: [
      for (final m in j['markers'] as List? ?? const [])
        MapMarker.fromJson(Map<String, dynamic>.from(m as Map)),
    ],
    strokes: [
      for (final s in j['strokes'] as List? ?? const [])
        MapStroke.fromJson(Map<String, dynamic>.from(s as Map)),
    ],
  );

  final MapBackground background;
  final String? imageId;
  final List<MapMarker> markers;
  final List<MapStroke> strokes;

  bool get isEmpty =>
      markers.isEmpty && strokes.isEmpty && background == MapBackground.blank;

  MapBoard withBackground(MapBackground next, {String? imageId}) => MapBoard(
    background: next,
    imageId: next == MapBackground.image ? imageId : null,
    markers: markers,
    strokes: strokes,
  );

  MapBoard _with({List<MapMarker>? markers, List<MapStroke>? strokes}) =>
      MapBoard(
        background: background,
        imageId: imageId,
        markers: markers ?? this.markers,
        strokes: strokes ?? this.strokes,
      );

  MapBoard addMarker(MapMarker marker) => _with(markers: [...markers, marker]);

  MapBoard replaceMarker(MapMarker marker) =>
      _with(markers: [for (final m in markers) m.id == marker.id ? marker : m]);

  MapBoard removeMarker(String id) =>
      _with(markers: markers.where((m) => m.id != id).toList());

  MapBoard addStroke(MapStroke stroke) => _with(strokes: [...strokes, stroke]);

  MapBoard removeStroke(String id) =>
      _with(strokes: strokes.where((s) => s.id != id).toList());

  Map<String, dynamic> toJson() => {
    'background': background.name,
    if (imageId != null) 'imageId': imageId,
    'markers': markers.map((m) => m.toJson()).toList(),
    'strokes': strokes.map((s) => s.toJson()).toList(),
  };
}
