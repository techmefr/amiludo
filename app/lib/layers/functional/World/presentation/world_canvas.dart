import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/World/domain/entities/map_element.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_map.dart';
import 'package:amiludo/layers/functional/World/presentation/draw_tool.dart';
import 'package:amiludo/layers/functional/World/presentation/world_painter.dart';
import 'package:amiludo/layers/functional/World/presentation/world_palette.dart';
import 'package:amiludo/layers/functional/World/presentation/world_viewport.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const _wheelZoom = 300.0;
const _eraseReach = 16.0;
const _inertiaSeconds = .35;

class WorldCanvas extends StatefulWidget {
  const WorldCanvas({
    super.key,
    required this.map,
    required this.floorId,
    required this.tool,
    required this.brush,
    required this.controller,
    required this.onAdd,
    required this.onErase,
  });
  final WorldMap map;
  final String floorId;
  final DrawTool tool;
  final double brush;
  final WorldViewportController controller;
  final ValueChanged<MapElement> onAdd;
  final ValueChanged<String> onErase;

  @override
  State<WorldCanvas> createState() => _WorldCanvasState();
}

class _WorldCanvasState extends State<WorldCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController motion = AnimationController(vsync: this);
  WorldViewport? from, to;
  MapElement? draft;
  bool panning = false;
  double startScale = 1;
  Offset lastPoint = Offset.zero;

  WorldViewportController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    c.animator = _animate;
    motion.addListener(() {
      final v = WorldViewport.lerp(from, to, Curves.easeOutCubic.transform(motion.value));
      if (v != null) c.viewport = v;
    });
  }

  @override
  void dispose() {
    c.animator = null;
    motion.dispose();
    super.dispose();
  }

  void _animate(WorldViewport target) {
    final instant = MediaQuery.disableAnimationsOf(context);
    motion.stop();
    if (instant) {
      c.viewport = target;
      return;
    }
    from = c.viewport;
    to = target;
    motion.duration = Motion.base;
    motion.forward(from: 0);
  }

  void _start(ScaleStartDetails d) {
    motion.stop();
    startScale = c.viewport.scale;
    lastPoint = d.localFocalPoint;
    final multi = d.pointerCount > 1;
    panning = multi || !(widget.tool.drawsStroke || widget.tool.drawsRoom);
    if (panning) return;
    final world = c.viewport.toWorld(d.localFocalPoint);
    final kind = widget.tool.kind!;
    setState(
      () => draft = MapElement(
        id: newElementId(),
        kind: kind,
        points: [world, world],
        width: widget.brush,
      ),
    );
  }

  void _update(ScaleUpdateDetails d) {
    if (d.pointerCount > 1 && !panning) {
      setState(() => draft = null);
      panning = true;
      startScale = c.viewport.scale;
    }
    if (panning) {
      final delta = d.localFocalPoint - lastPoint;
      lastPoint = d.localFocalPoint;
      var next = c.viewport.panned(delta);
      if (d.pointerCount > 1) {
        next = next.zoomed(startScale * d.scale, d.localFocalPoint);
      }
      c.viewport = next;
      return;
    }
    final current = draft;
    if (current == null) return;
    final world = c.viewport.toWorld(d.localFocalPoint);
    if (current.kind == ElementKind.room) {
      setState(() => draft = _room(current, world));
    } else if ((d.localFocalPoint - lastPoint).distance > 6) {
      lastPoint = d.localFocalPoint;
      setState(
        () => draft = _with(current, [...current.points, world]),
      );
    }
  }

  MapElement _with(MapElement e, List<WorldPoint> points) => MapElement(
    id: e.id,
    kind: e.kind,
    points: points,
    width: e.width,
  );

  MapElement _room(MapElement e, WorldPoint to) =>
      _with(e, [e.points.first, to]);

  void _end(ScaleEndDetails d) {
    final done = draft;
    if (done != null) {
      setState(() => draft = null);
      final long = done.points.length > 2 ||
          done.points.first.distanceTo(done.points.last) > gridCell / 2;
      if (long) widget.onAdd(done);
      return;
    }
    if (!panning) return;
    final v = d.velocity.pixelsPerSecond;
    if (v.distance < 200) return;
    _animate(c.viewport.panned(v * _inertiaSeconds));
  }

  void _tap(TapUpDetails d) {
    final world = c.viewport.toWorld(d.localPosition);
    if (widget.tool.placesSymbol) {
      widget.onAdd(
        MapElement(id: newElementId(), kind: widget.tool.kind!, points: [world]),
      );
    } else if (widget.tool == DrawTool.erase) {
      final floor = widget.map.floor(widget.floorId);
      final hit = floor?.nearest(world, _eraseReach / c.viewport.scale);
      if (hit != null) widget.onErase(hit.id);
    }
  }

  Offset doubleAt = Offset.zero;

  void _doubleTap() => _animate(c.viewport.zoomedBy(2, doubleAt));

  void _wheel(PointerSignalEvent e) {
    if (e is! PointerScrollEvent) return;
    c.viewport = c.viewport.zoomedBy(
      exp(-e.scrollDelta.dy / _wheelZoom),
      e.localPosition,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = WorldPalette.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        c.place(box.biggest);
        return Listener(
          onPointerSignal: _wheel,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            dragStartBehavior: DragStartBehavior.down,
            onScaleStart: _start,
            onScaleUpdate: _update,
            onScaleEnd: _end,
            onTapUp: _tap,
            onDoubleTapDown: (d) => doubleAt = d.localPosition,
            onDoubleTap: widget.tool == DrawTool.move ? _doubleTap : null,
            child: ClipRect(
              child: ListenableBuilder(
                listenable: c,
                builder: (context, _) {
                  final floor = widget.map.floor(widget.floorId);
                  return CustomPaint(
                    size: Size.infinite,
                    painter: WorldPainter(
                      elements: floor?.elements ?? const [],
                      ghost: widget.map.below(widget.floorId)?.elements ?? const [],
                      viewport: c.viewport,
                      palette: palette,
                      grid: widget.map.grid,
                      draft: draft,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
