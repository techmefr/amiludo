import 'dart:math';
import 'dart:ui';

import 'package:amiludo/layers/functional/Companion/domain/entities/map_board.dart';

const mapMarkerSize = 40.0;
const mapHitRadius = 28.0;
const mapStrokeHit = 16.0;

class MapView {
  const MapView({required this.fit, required this.scale, required this.offset});

  final double fit, scale;
  final Offset offset;

  double get unit => fit * scale;

  Offset toScreen(MapPoint p) => Offset(p.x * unit, p.y * unit) + offset;

  MapPoint toWorld(Offset screen) {
    final local = (screen - offset) / unit;
    return MapPoint(
      local.dx.clamp(0.0, mapWorld).toDouble(),
      local.dy.clamp(0.0, mapWorld).toDouble(),
    );
  }

  Rect get sheet => offset & Size(mapWorld * unit, mapWorld * unit);

  Offset markerCenter(MapMarker m) {
    final tip = toScreen(MapPoint(m.x, m.y));
    return m.kind == MapMarkerKind.pin
        ? tip - const Offset(0, mapMarkerSize / 2 + 4)
        : tip;
  }

  MapMarker? markerAt(Iterable<MapMarker> markers, Offset screen) {
    MapMarker? best;
    var bestDistance = mapHitRadius;
    for (final m in markers) {
      final d = (markerCenter(m) - screen).distance;
      if (d <= bestDistance) {
        best = m;
        bestDistance = d;
      }
    }
    return best;
  }

  MapStroke? strokeAt(Iterable<MapStroke> strokes, Offset screen) {
    for (final s in strokes.toList().reversed) {
      final points = [for (final p in s.points) toScreen(p)];
      if (s.kind == MapStrokeKind.zone && points.length > 2) {
        points.add(points.first);
      }
      for (var i = 0; i < points.length - 1; i++) {
        if (_segmentDistance(screen, points[i], points[i + 1]) <= mapStrokeHit) {
          return s;
        }
      }
    }
    return null;
  }
}

double _segmentDistance(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final lengthSquared = ab.dx * ab.dx + ab.dy * ab.dy;
  if (lengthSquared == 0) return (p - a).distance;
  final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / lengthSquared).clamp(
    0.0,
    1.0,
  );
  return (p - (a + ab * t)).distance;
}

double mapFit(Size size) => min(size.width, size.height) / mapWorld;
