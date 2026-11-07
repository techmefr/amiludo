import 'package:amiludo/layers/functional/Companion/domain/entities/map_board_state.dart';

const freeMapKey = 'free';

class MapBoards {
  const MapBoards({this.boards = const {}});

  factory MapBoards.fromJson(Map<String, dynamic> j) => MapBoards(
    boards: {
      for (final e in Map<String, dynamic>.from(
        j['maps'] as Map? ?? const {},
      ).entries)
        e.key: MapBoard.fromJson(Map<String, dynamic>.from(e.value as Map)),
    },
  );

  final Map<String, MapBoard> boards;

  bool get isEmpty => boards.isEmpty;

  MapBoard of(String key) => boards[key] ?? const MapBoard();

  MapBoards put(String key, MapBoard board) {
    final next = {...boards}..remove(key);
    if (!board.isEmpty) next[key] = board;
    return MapBoards(boards: next);
  }

  Map<String, Object?> toJson() => {
    'maps': {for (final e in boards.entries) e.key: e.value.toJson()},
  };
}
