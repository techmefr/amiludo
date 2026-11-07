import 'dart:typed_data';

import 'package:amiludo/layers/functional/Companion/domain/entities/map_boards.dart';

abstract class MapBoardsGateway {
  MapBoards get current;
  Stream<MapBoards> get changes;
  Future<void> save(MapBoards boards);
}

abstract class MapImageGateway {
  Future<Uint8List?> read(String id);
  Future<void> write(String id, List<int> bytes);
  Future<void> delete(String id);
}
