import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:amiludo/layers/technical/Theme/components/parchment_sheet.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/map_board.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/map_board_state.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_controller.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_geometry.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_marker_view.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_painter.dart';

const mapWheelZoom = 300.0;

enum _Gesture { none, pan, drag, draw }

class MapCanvas extends StatefulWidget {
  const MapCanvas({
    super.key,
    required this.controller,
    required this.onEdit,
    this.image,
  });
  final MapController controller;
  final ValueChanged<MapMarker> onEdit;
  final ui.Image? image;

  @override
  State<MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<MapCanvas> {
  Size size = Size.zero;
  _Gesture gesture = _Gesture.none;
  MapMarker? dragged;
  MapBoard? before;
  bool moved = false, fresh = false;
  int pointers = 0;
  Offset down = Offset.zero;
  double startScale = 1;
  Offset anchor = Offset.zero, grab = Offset.zero;

  MapController get c => widget.controller;

  MapView view() {
    final fit = mapFit(size);
    final side = mapWorld * fit * c.scale;
    final offset =
        c.offset ?? Offset((size.width - side) / 2, (size.height - side) / 2);
    return MapView(fit: fit, scale: c.scale, offset: offset);
  }

  void start(ScaleStartDetails d) {
    final v = view();
    final focal = fresh && d.pointerCount == 1 ? down : d.localFocalPoint;
    fresh = false;
    startScale = c.scale;
    anchor = (focal - v.offset) / v.unit;
    moved = false;
    gesture = _Gesture.pan;
    if (d.pointerCount > 1) return;
    if (c.tool == MapTool.move) {
      final hit = v.markerAt(c.board.markers, focal);
      if (hit == null) return;
      dragged = hit;
      before = c.board;
      grab = v.toScreen(MapPoint(hit.x, hit.y)) - focal;
      gesture = _Gesture.drag;
    } else if (c.tool == MapTool.line || c.tool == MapTool.zone) {
      gesture = _Gesture.draw;
      c.beginStroke(v.toWorld(focal));
    }
  }

  void update(ScaleUpdateDetails d) {
    final v = view();
    moved = true;
    switch (gesture) {
      case _Gesture.drag:
        c.dragMarker(dragged!, v.toWorld(d.localFocalPoint + grab));
      case _Gesture.draw:
        c.extendStroke(v.toWorld(d.localFocalPoint));
      case _Gesture.pan:
        zoom(startScale * d.scale, d.localFocalPoint, anchor);
      case _Gesture.none:
        break;
    }
  }

  void zoom(double next, Offset focal, Offset local) {
    final scale = next.clamp(mapMinScale, mapMaxScale).toDouble();
    c.transform(scale, focal - local * (mapFit(size) * scale));
  }

  void end(ScaleEndDetails d) {
    if (gesture == _Gesture.draw) c.endStroke();
    if (gesture == _Gesture.drag && moved) c.dropMarker(before!);
    gesture = _Gesture.none;
    dragged = null;
  }

  void tap(TapUpDetails d) {
    final v = view();
    final at = d.localPosition;
    final hit = v.markerAt(c.board.markers, at);
    switch (c.tool) {
      case MapTool.move:
        if (hit != null) widget.onEdit(hit);
      case MapTool.pin || MapTool.token:
        if (hit != null) return widget.onEdit(hit);
        if (!v.sheet.contains(at)) return;
        c.addMarker(
          c.tool == MapTool.pin ? MapMarkerKind.pin : MapMarkerKind.token,
          v.toWorld(at),
        );
      case MapTool.erase:
        if (hit != null) return c.removeMarker(hit.id);
        final stroke = v.strokeAt(c.board.strokes, at);
        if (stroke != null) c.eraseStroke(stroke.id);
      case MapTool.line || MapTool.zone:
        break;
    }
  }

  void pointerDown(PointerDownEvent e) {
    pointers++;
    if (pointers != 1) return;
    down = e.localPosition;
    fresh = true;
  }

  void wheel(PointerSignalEvent e) {
    if (e is! PointerScrollEvent) return;
    final v = view();
    final local = (e.localPosition - v.offset) / v.unit;
    final next = c.scale * exp(-e.scrollDelta.dy / mapWheelZoom);
    zoom(next, e.localPosition, local);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        size = box.biggest;
        return Listener(
          onPointerSignal: wheel,
          onPointerDown: pointerDown,
          onPointerUp: (_) => pointers = max(0, pointers - 1),
          onPointerCancel: (_) => pointers = max(0, pointers - 1),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            dragStartBehavior: DragStartBehavior.down,
            onScaleStart: start,
            onScaleUpdate: update,
            onScaleEnd: end,
            onTapUp: tap,
            child: ClipRect(
              child: ListenableBuilder(
                listenable: c,
                builder: (context, _) {
                  final v = view();
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      const ColoredBox(color: ParchmentPalette.sea),
                      CustomPaint(
                        painter: MapPainter(
                          board: c.board,
                          view: v,
                          paper: ParchmentPalette.land,
                          ink: ParchmentPalette.ink,
                          draft: c.draft,
                          draftKind: c.tool == MapTool.zone
                              ? MapStrokeKind.zone
                              : MapStrokeKind.line,
                          draftColor: c.color,
                          image: widget.image,
                        ),
                      ),
                      for (final m in c.board.markers)
                        MapMarkerView(marker: m, center: v.markerCenter(m)),
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
