import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/map_board.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/map_board_state.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_geometry.dart';

const mapGridStep = 50.0;
const mapHexRadius = 40.0;
const mapZoneAlpha = 0.28;
const mapLineWidth = 4.0;

class MapPainter extends CustomPainter {
  MapPainter({
    required this.board,
    required this.view,
    required this.paper,
    required this.ink,
    this.draft = const [],
    this.draftKind = MapStrokeKind.line,
    this.draftColor = 0xFF3D7BD9,
    this.image,
  });

  final MapBoard board;
  final MapView view;
  final Color paper, ink;
  final List<MapPoint> draft;
  final MapStrokeKind draftKind;
  final int draftColor;
  final ui.Image? image;

  @override
  void paint(Canvas canvas, Size size) {
    final sheet = view.sheet;
    canvas.save();
    canvas.clipRect(sheet);
    canvas.drawRect(sheet, Paint()..color = paper);
    switch (board.background) {
      case MapBackground.grid:
        _grid(canvas);
      case MapBackground.hex:
        _hex(canvas);
      case MapBackground.image:
        _image(canvas, sheet);
      case MapBackground.blank:
        break;
    }
    for (final s in board.strokes) {
      _stroke(canvas, s.points, s.kind, s.color);
    }
    _stroke(canvas, draft, draftKind, draftColor);
    canvas.restore();
    canvas.drawRect(
      sheet,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = ink.withValues(alpha: 0.4),
    );
  }

  Paint get _line => Paint()
    ..style = PaintingStyle.stroke
    ..color = ink.withValues(alpha: 0.18);

  void _grid(Canvas canvas) {
    final paint = _line;
    for (var v = 0.0; v <= mapWorld; v += mapGridStep) {
      canvas.drawLine(
        view.toScreen(MapPoint(v, 0)),
        view.toScreen(MapPoint(v, mapWorld)),
        paint,
      );
      canvas.drawLine(
        view.toScreen(MapPoint(0, v)),
        view.toScreen(MapPoint(mapWorld, v)),
        paint,
      );
    }
  }

  void _hex(Canvas canvas) {
    final paint = _line;
    final width = sqrt(3) * mapHexRadius;
    var row = 0;
    for (var y = 0.0; y <= mapWorld + mapHexRadius; y += mapHexRadius * 1.5) {
      final shift = row.isOdd ? width / 2 : 0.0;
      for (var x = shift; x <= mapWorld + width; x += width) {
        final path = Path();
        for (var i = 0; i < 6; i++) {
          final a = pi / 3 * i + pi / 6;
          final p = view.toScreen(
            MapPoint(x + mapHexRadius * cos(a), y + mapHexRadius * sin(a)),
          );
          i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(path..close(), paint);
      }
      row++;
    }
  }

  void _image(Canvas canvas, Rect sheet) {
    final source = image;
    if (source == null) return;
    paintImage(canvas: canvas, rect: sheet, image: source, fit: BoxFit.contain);
  }

  void _stroke(
    Canvas canvas,
    List<MapPoint> points,
    MapStrokeKind kind,
    int c,
  ) {
    if (points.length < 2) return;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final p = view.toScreen(points[i]);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    final color = Color(c);
    if (kind == MapStrokeKind.zone) {
      canvas.drawPath(
        Path.from(path)..close(),
        Paint()..color = color.withValues(alpha: mapZoneAlpha),
      );
      path.close();
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = mapLineWidth
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(MapPainter old) => true;
}
