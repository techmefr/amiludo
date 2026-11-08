import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/World/domain/entities/map_element.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_map.dart';
import 'package:amiludo/layers/functional/World/presentation/world_palette.dart';
import 'package:amiludo/layers/functional/World/presentation/world_viewport.dart';

class WorldPainter extends CustomPainter {
  WorldPainter({
    required this.elements,
    required this.ghost,
    required this.viewport,
    required this.palette,
    required this.grid,
    this.draft,
    this.measure,
    super.repaint,
  });

  final List<MapElement> elements, ghost;
  final WorldViewport viewport;
  final WorldPalette palette;
  final bool grid;
  final MapElement? draft;
  final (WorldPoint, WorldPoint)? measure;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = palette.paper);
    if (grid) _grid(canvas, size);
    for (final e in ghost) {
      _element(canvas, e, .22);
    }
    for (final e in elements) {
      _element(canvas, e, 1);
    }
    final d = draft;
    if (d != null) _element(canvas, d, .8);
    final m = measure;
    if (m != null) _measure(canvas, m.$1, m.$2);
  }

  void _measure(Canvas canvas, WorldPoint a, WorldPoint b) {
    final from = viewport.toScreen(a), to = viewport.toScreen(b);
    final paint = Paint()
      ..color = const Color(0xffD2603F)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(from, to, paint)
      ..drawCircle(from, 6, paint)
      ..drawCircle(to, 6, paint);
  }

  void _grid(Canvas canvas, Size size) {
    final step = gridCell * viewport.scale;
    if (step < 8) return;
    final paint = Paint()
      ..color = palette.grid
      ..strokeWidth = 1;
    var x = viewport.offset.dx % step;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      x += step;
    }
    var y = viewport.offset.dy % step;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += step;
    }
  }

  Path _path(List<WorldPoint> points) {
    final path = Path();
    for (final (i, p) in points.indexed) {
      final s = viewport.toScreen(p);
      i == 0 ? path.moveTo(s.dx, s.dy) : path.lineTo(s.dx, s.dy);
    }
    return path;
  }

  void _element(Canvas canvas, MapElement e, double alpha) {
    if (e.points.isEmpty) return;
    final scale = viewport.scale;
    switch (e.kind) {
      case ElementKind.land ||
          ElementKind.water ||
          ElementKind.forest ||
          ElementKind.mountain:
        _brush(canvas, e, alpha);
      case ElementKind.road || ElementKind.river || ElementKind.wall:
        final color = palette.lines[e.kind]!.withValues(alpha: alpha);
        final wide = e.kind == ElementKind.river ? 9.0 : 5.0;
        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(2, wide * scale)
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        final path = _path(e.points);
        if (e.kind == ElementKind.road) {
          for (final m in path.computeMetrics()) {
            var at = 0.0;
            final dash = max(6.0, 14 * scale);
            while (at < m.length) {
              canvas.drawPath(m.extractPath(at, at + dash), paint);
              at += dash * 1.9;
            }
          }
        } else {
          canvas.drawPath(path, paint);
        }
      case ElementKind.room:
        final a = viewport.toScreen(e.points.first);
        final b = viewport.toScreen(e.points.last);
        final rect = Rect.fromPoints(a, b);
        canvas
          ..drawRect(rect, Paint()..color = palette.room.withValues(alpha: alpha))
          ..drawRect(
            rect,
            Paint()
              ..color = palette.ink.withValues(alpha: alpha)
              ..style = PaintingStyle.stroke
              ..strokeWidth = max(2, 4 * scale),
          );
      case ElementKind.door:
        final c = viewport.toScreen(e.points.first);
        final w = max(8.0, 26 * scale);
        canvas.drawRect(
          Rect.fromCenter(center: c, width: w, height: w * .45),
          Paint()..color = palette.lines[ElementKind.road]!.withValues(alpha: alpha),
        );
      case ElementKind.stairs:
        final c = viewport.toScreen(e.points.first);
        final w = max(10.0, 30 * scale);
        final line = Paint()
          ..color = palette.ink.withValues(alpha: alpha)
          ..strokeWidth = max(1.5, 3 * scale);
        for (var i = -2; i <= 2; i++) {
          final y = c.dy + i * w * .22;
          canvas.drawLine(Offset(c.dx - w / 2, y), Offset(c.dx + w / 2, y), line);
        }
    }
  }

  void _brush(Canvas canvas, MapElement e, double alpha) {
    final fill = palette.fills[e.kind]!.withValues(alpha: alpha);
    final width = e.width * viewport.scale;
    canvas.drawPath(
      _path(e.points),
      Paint()
        ..color = fill
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    if (e.kind == ElementKind.water || e.kind == ElementKind.land) return;
    final mark = Paint()
      ..color = palette.ink.withValues(alpha: alpha * .7)
      ..style = e.kind == ElementKind.forest
          ? PaintingStyle.fill
          : PaintingStyle.stroke
      ..strokeWidth = max(1, 2 * viewport.scale);
    final size = max(3.0, width * .14);
    for (final (i, p) in e.points.indexed) {
      if (i % 3 != 0) continue;
      final s = viewport.toScreen(p);
      if (e.kind == ElementKind.forest) {
        canvas.drawCircle(s, size, mark);
      } else {
        canvas.drawPath(
          Path()
            ..moveTo(s.dx - size, s.dy + size)
            ..lineTo(s.dx, s.dy - size)
            ..lineTo(s.dx + size, s.dy + size),
          mark,
        );
      }
    }
  }

  @override
  bool shouldRepaint(WorldPainter old) => true;
}
