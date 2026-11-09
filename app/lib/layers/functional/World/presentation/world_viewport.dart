import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/World/domain/entities/map_element.dart';

const worldMinZoom = .12;
const worldMaxZoom = 8.0;

class WorldViewport {
  const WorldViewport({this.scale = 1, this.offset = Offset.zero});

  final double scale;
  final Offset offset;

  Offset toScreen(WorldPoint p) =>
      Offset(p.x * scale + offset.dx, p.y * scale + offset.dy);

  WorldPoint toWorld(Offset s) =>
      WorldPoint((s.dx - offset.dx) / scale, (s.dy - offset.dy) / scale);

  WorldViewport panned(Offset delta) =>
      WorldViewport(scale: scale, offset: offset + delta);

  WorldViewport zoomed(double target, Offset focal) {
    final next = target.clamp(worldMinZoom, worldMaxZoom).toDouble();
    final anchor = toWorld(focal);
    return WorldViewport(
      scale: next,
      offset: Offset(focal.dx - anchor.x * next, focal.dy - anchor.y * next),
    );
  }

  WorldViewport zoomedBy(double factor, Offset focal) =>
      zoomed(scale * factor, focal);

  static WorldViewport centered(Size size) =>
      WorldViewport(offset: Offset(size.width / 2, size.height / 2));

  static WorldViewport? lerp(WorldViewport? a, WorldViewport? b, double t) {
    if (a == null || b == null) return b;
    return WorldViewport(
      scale: a.scale * pow(b.scale / a.scale, t),
      offset: Offset.lerp(a.offset, b.offset, t)!,
    );
  }
}

class WorldViewportController extends ChangeNotifier {
  WorldViewport _viewport = const WorldViewport();
  Size size = Size.zero;
  bool placed = false;
  void Function(WorldViewport target)? animator;

  WorldViewport get viewport => _viewport;

  set viewport(WorldViewport next) {
    _viewport = next;
    notifyListeners();
  }

  void place(Size next) {
    size = next;
    if (placed) return;
    placed = true;
    _viewport = WorldViewport.centered(next);
  }

  void reset() => _go(WorldViewport.centered(size));

  void centerOn(WorldPoint p) => _go(
    WorldViewport(
      scale: _viewport.scale,
      offset: Offset(
        size.width / 2 - p.x * _viewport.scale,
        size.height / 2 - p.y * _viewport.scale,
      ),
    ),
  );

  void zoomBy(double factor) => _go(
    _viewport.zoomedBy(factor, Offset(size.width / 2, size.height / 2)),
  );

  void _go(WorldViewport target) {
    final run = animator;
    if (run == null) {
      viewport = target;
    } else {
      run(target);
    }
  }
}
