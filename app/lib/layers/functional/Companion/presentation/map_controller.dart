import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/map_board.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/map_board_state.dart';

enum MapTool { move, pin, token, line, zone, erase }

const mapHistoryLimit = 50;
const mapMinScale = 0.5;
const mapMaxScale = 8.0;

class MapController extends ChangeNotifier {
  MapController(this._board, {this.onChanged});

  MapBoard _board;
  final ValueChanged<MapBoard>? onChanged;
  final _history = <MapBoard>[];
  MapTool tool = MapTool.move;
  int color = mapPalette.first;
  String icon = mapDefaultIcon;
  double scale = 1;
  Offset? offset;
  List<MapPoint> draft = const [];

  MapBoard get board => _board;

  bool get canUndo => _history.isNotEmpty;

  void select(MapTool next) {
    tool = next;
    notifyListeners();
  }

  void setColor(int value) {
    color = value;
    notifyListeners();
  }

  void setIcon(String value) {
    icon = value;
    notifyListeners();
  }

  void commit(MapBoard next) {
    _history.add(_board);
    if (_history.length > mapHistoryLimit) _history.removeAt(0);
    _board = next;
    onChanged?.call(next);
    notifyListeners();
  }

  void undo() {
    if (_history.isEmpty) return;
    _board = _history.removeLast();
    onChanged?.call(_board);
    notifyListeners();
  }

  void setBackground(MapBackground background, {String? imageId}) =>
      commit(_board.withBackground(background, imageId: imageId));

  void addMarker(MapMarkerKind kind, MapPoint at) => commit(
    _board.addMarker(
      MapMarker(
        id: mapItemId(),
        x: at.x,
        y: at.y,
        kind: kind,
        color: color,
        icon: icon,
      ),
    ),
  );

  void editMarker(MapMarker marker) => commit(_board.replaceMarker(marker));

  void removeMarker(String id) => commit(_board.removeMarker(id));

  void dragMarker(MapMarker marker, MapPoint to) {
    _board = _board.replaceMarker(marker.copyWith(x: to.x, y: to.y));
    notifyListeners();
  }

  void dropMarker(MapBoard before) {
    _history.add(before);
    onChanged?.call(_board);
    notifyListeners();
  }

  void beginStroke(MapPoint at) {
    draft = [at];
    notifyListeners();
  }

  void extendStroke(MapPoint at) {
    if (draft.length >= mapMaxStrokePoints) return;
    draft = [...draft, at];
    notifyListeners();
  }

  void endStroke() {
    final points = draft;
    draft = const [];
    if (points.length < 2) return notifyListeners();
    commit(
      _board.addStroke(
        MapStroke(
          id: mapItemId(),
          points: points,
          color: color,
          kind: tool == MapTool.zone ? MapStrokeKind.zone : MapStrokeKind.line,
        ),
      ),
    );
  }

  void eraseStroke(String id) => commit(_board.removeStroke(id));

  void transform(double nextScale, Offset nextOffset) {
    scale = nextScale.clamp(mapMinScale, mapMaxScale);
    offset = nextOffset;
    notifyListeners();
  }
}
