import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/World/domain/entities/map_element.dart';
import 'package:amiludo/layers/functional/World/domain/entities/map_floor.dart';
import 'package:amiludo/layers/functional/World/presentation/pin_marker.dart';
import 'package:amiludo/layers/functional/World/presentation/world_palette.dart';
import 'package:amiludo/layers/functional/World/presentation/world_viewport.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const miniMapSize = Size(112, 84);

Rect? worldBounds(MapFloor floor) {
  final points = [
    for (final e in floor.elements) ...e.points,
    for (final p in floor.pins) p.point,
  ];
  if (points.isEmpty) return null;
  var left = points.first.x, right = left;
  var top = points.first.y, bottom = top;
  for (final p in points) {
    left = min(left, p.x);
    right = max(right, p.x);
    top = min(top, p.y);
    bottom = max(bottom, p.y);
  }
  return Rect.fromLTRB(left - 40, top - 40, right + 40, bottom + 40);
}

class MiniMap extends StatelessWidget {
  const MiniMap({
    super.key,
    required this.floor,
    required this.controller,
    required this.onJump,
  });
  final MapFloor floor;
  final WorldViewportController controller;
  final ValueChanged<WorldPoint> onJump;

  @override
  Widget build(BuildContext context) {
    final bounds = worldBounds(floor);
    if (bounds == null) return const SizedBox.shrink();
    final palette = WorldPalette.of(context);
    return Semantics(
      label: context.l10n.worldMiniMap,
      button: true,
      child: GestureDetector(
        onTapUp: (d) {
          final fit = _fit(bounds);
          onJump(
            WorldPoint(
              bounds.left + (d.localPosition.dx - fit.dx) / fit.scale,
              bounds.top + (d.localPosition.dy - fit.dy) / fit.scale,
            ),
          );
        },
        child: Container(
          width: miniMapSize.width,
          height: miniMapSize.height,
          decoration: BoxDecoration(
            color: palette.paper.withValues(alpha: .92),
            borderRadius: BorderRadius.circular(Radii.sm),
            border: Border.all(color: palette.ink.withValues(alpha: .6)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Radii.sm),
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) => CustomPaint(
                painter: _MiniPainter(
                  floor: floor,
                  bounds: bounds,
                  palette: palette,
                  viewport: controller.viewport,
                  screen: controller.size,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

({double scale, double dx, double dy}) _fit(Rect bounds) {
  final scale = min(
    miniMapSize.width / bounds.width,
    miniMapSize.height / bounds.height,
  );
  return (
    scale: scale,
    dx: (miniMapSize.width - bounds.width * scale) / 2,
    dy: (miniMapSize.height - bounds.height * scale) / 2,
  );
}

class _MiniPainter extends CustomPainter {
  _MiniPainter({
    required this.floor,
    required this.bounds,
    required this.palette,
    required this.viewport,
    required this.screen,
  });
  final MapFloor floor;
  final Rect bounds;
  final WorldPalette palette;
  final WorldViewport viewport;
  final Size screen;

  Offset _to(WorldPoint p) {
    final f = _fit(bounds);
    return Offset(
      f.dx + (p.x - bounds.left) * f.scale,
      f.dy + (p.y - bounds.top) * f.scale,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final e in floor.elements) {
      if (e.points.isEmpty) continue;
      final color =
          palette.fills[e.kind] ?? palette.lines[e.kind] ?? palette.ink;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = e.kind.isBrush ? max(2, e.width * _fit(bounds).scale) : 1.5;
      final path = Path();
      for (final (i, p) in e.points.indexed) {
        final o = _to(p);
        if (i == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      if (e.points.length == 1) {
        canvas.drawCircle(_to(e.points.first), 1.5, paint..style = PaintingStyle.fill);
      } else {
        canvas.drawPath(path, paint);
      }
    }
    for (final p in floor.pins) {
      canvas.drawCircle(_to(p.point), 3, Paint()..color = pinColors[p.kind]!);
    }
    final a = _to(viewport.toWorld(Offset.zero));
    final b = _to(viewport.toWorld(Offset(screen.width, screen.height)));
    canvas.drawRect(
      Rect.fromPoints(a, b),
      Paint()
        ..color = palette.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_MiniPainter old) => true;
}
