import 'dart:typed_data';

import 'package:amiludo/layers/functional/Companion/domain/entities/map_board_state.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/map_board.dart';
import 'package:amiludo/layers/functional/Companion/domain/gateways/map_gateways.dart';

class ReadMapUseCase {
  ReadMapUseCase(this._maps);
  final MapBoardsGateway _maps;

  MapBoard call(String key) => _maps.current.of(key);
}

class SaveMapUseCase {
  SaveMapUseCase(this._maps, this._images);
  final MapBoardsGateway _maps;
  final MapImageGateway _images;

  Future<void> call(String key, MapBoard board) async {
    final before = _maps.current.of(key).imageId;
    await _maps.save(_maps.current.put(key, board));
    if (before == null || before == board.imageId) return;
    final used = {
      for (final b in _maps.current.boards.values) b.imageId,
    };
    if (!used.contains(before)) await _images.delete(before);
  }
}

class ImportMapImageUseCase {
  ImportMapImageUseCase(this._images);
  final MapImageGateway _images;

  Future<String> call(List<int> bytes) async {
    final id = mapItemId();
    await _images.write(id, bytes);
    return id;
  }
}

class ReadMapImageUseCase {
  ReadMapImageUseCase(this._images);
  final MapImageGateway _images;

  Future<Uint8List?> call(String id) => _images.read(id);
}
