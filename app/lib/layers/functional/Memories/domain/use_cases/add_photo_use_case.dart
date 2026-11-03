import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Memories/domain/gateways/memories_gateway.dart';
import 'package:amiludo/layers/functional/Memories/domain/gateways/photo_gateway.dart';

class AddPhotoUseCase {
  AddPhotoUseCase(this._memories, this._photos);

  static const maxBytes = 8000000;
  static const maxPhotos = 60;

  final MemoriesGateway _memories;
  final PhotoGateway _photos;

  Future<void> call(String sessionId, List<int> bytes) async {
    final memory = _memories.current.memoryOf(sessionId);
    if (bytes.length > maxBytes) {
      throw const FormatException('Photo trop lourde (8 Mo maximum).');
    }
    if (memory.photoIds.length >= maxPhotos) {
      throw const FormatException('60 photos maximum par partie.');
    }
    final id = '$sessionId-${newId()}';
    await _photos.write(id, bytes);
    final latest = _memories.current;
    final saved = latest.memoryOf(sessionId);
    await _memories.save(
      latest.withMemory(saved.copyWith(photoIds: [...saved.photoIds, id])),
    );
  }
}
