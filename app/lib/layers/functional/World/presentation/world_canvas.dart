import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/World/domain/entities/map_element.dart';
import 'package:amiludo/layers/functional/World/domain/entities/map_pin.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_map.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_map_pins.dart';
import 'package:amiludo/layers/functional/World/presentation/draw_tool.dart';
import 'package:amiludo/layers/functional/World/presentation/pin_marker.dart';
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
    required this.onPlacePin,
    required this.onOpenPin,
    required this.onMovePin,
    required this.onMeasure,
  });
  final WorldMap map;
  final String floorId;
  final DrawTool tool;
  final double brush;
  final WorldViewportController controller;
  final ValueChanged<MapElement> onAdd;
  final ValueChanged<String> onErase;
  final ValueChanged<WorldPoint> onPlacePin;
  final ValueChanged<MapPin> onOpenPin;
  final void Function(String id, Offset delta) onMovePin;
  final ValueChanged<String?> onMeasure;

  @override
  State<WorldCanvas> createState() => _WorldCanvasState();
}

class _WorldCanvasState extends State<WorldCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController motion = AnimationController(vsync: this);
  WorldViewport? from, to;
  MapElement? draft;
  (WorldPoint, WorldPoint)? ruler;
  bool panning = false;
  double startScale = 1;
  Offset lastPoint = Offset.zero, doubleAt = Offset.zero;

  WorldViewportController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    c.animator = _animate;
    motion.addListener(() {
      final curve = Curves.easeOutCubic.transform(motion.value);
      final v = WorldViewport.lerp(from, to, curve);
      if (v != null) c.viewport = v;
    });
  }

  @override
  void didUpdateWidget(WorldCanvas old) {
    super.didUpdateWidget(old);
    if (old.tool != widget.tool && ruler != null) {
      ruler = null;
      widget.onMeasure(null);
    }
  }

  @override
  void dispose() {
    c.animator = null;
    motion.dispose();
    super.dispose();
  }

  void _animate(WorldViewport target) {
    motion.stop();
    if (MediaQuery.disableAnimationsOf(context)) {
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
    final world = c.viewport.toWorld(d.localFocalPoint);
    panning =
        d.pointerCount > 1 ||
        !(widget.tool.drawsStroke ||
            widget.tool.drawsRoom ||
            widget.tool == DrawTool.measure);
    if (panning) return;
    if (widget.tool == DrawTool.measure) {
      setState(() => ruler = (world, world));
      return;
    }
    setState(
      () => draft = MapElement(
        id: newElementId(),
        kind: widget.tool.kind!,
        points: [world, world],
        width: widget.brush,
      ),
    );
  }

  void _update(ScaleUpdateDetails d) {
    if (d.pointerCount > 1 && !panning) {
      setState(() {
        draft = null;
        ruler = null;
      });
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
    final world = c.viewport.toWorld(d.localFocalPoint);
    final line = ruler;
    if (line != null) {
      setState(() => ruler = (line.$1, world));
      widget.onMeasure(
        formatMeters(widget.map.metersBetween(line.$1, world)),
      );
      return;
    }
    final current = draft;
    if (current == null) return;
    if (current.kind == ElementKind.room) {
      setState(() => draft = _with(current, [current.points.first, world]));
    } else if ((d.localFocalPoint - lastPoint).distance > 6) {
      lastPoint = d.localFocalPoint;
      setState(() => draft = _with(current, [...current.points, world]));
    }
  }

  MapElement _with(MapElement e, List<WorldPoint> points) => MapElement(
    id: e.id,
    kind: e.kind,
    points: points,
    width: e.width,
  );

  void _end(ScaleEndDetails d) {
    final done = draft;
    if (done != null) {
      setState(() => draft = null);
      final long =
          done.points.length > 2 ||
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
    final tool = widget.tool;
    if (tool.placesSymbol) {
      widget.onAdd(
        MapElement(id: newElementId(), kind: tool.kind!, points: [world]),
      );
    } else if (tool == DrawTool.pin) {
      widget.onPlacePin(world);
    } else if (tool == DrawTool.erase) {
      final floor = widget.map.floor(widget.floorId);
      final hit = floor?.nearest(world, _eraseReach / c.viewport.scale);
      if (hit != null) widget.onErase(hit.id);
    }
  }

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
    final move = widget.tool == DrawTool.move;
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
            onDoubleTapDown: move ? (d) => doubleAt = d.localPosition : null,
            onDoubleTap: move
                ? () => _animate(c.viewport.zoomedBy(2, doubleAt))
                : null,
            child: ClipRect(
              child: ListenableBuilder(
                listenable: c,
                builder: (context, _) {
                  final floor = widget.map.floor(widget.floorId);
                  final view = c.viewport;
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        painter: WorldPainter(
                          elements: floor?.elements ?? const [],
                          ghost:
                              widget.map.below(widget.floorId)?.elements ??
                              const [],
                          viewport: view,
                          palette: palette,
                          grid: widget.map.grid,
                          draft: draft,
                          measure: ruler,
                        ),
                      ),
                      for (final p in floor?.pins ?? const <MapPin>[])
                        PinMarker(
                          key: ValueKey(p.id),
                          pin: p,
                          center: view.toScreen(p.point),
                          scale: view.scale,
                          draggable: move,
                          onTap: () => widget.onOpenPin(p),
                          onMove: (delta) => widget.onMovePin(p.id, delta),
                        ),
                    ],
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
