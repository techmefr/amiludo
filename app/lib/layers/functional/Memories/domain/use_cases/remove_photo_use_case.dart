import 'package:amiludo/layers/functional/Memories/domain/gateways/memories_gateway.dart';
import 'package:amiludo/layers/functional/Memories/domain/gateways/photo_gateway.dart';

class RemovePhotoUseCase {
  RemovePhotoUseCase(this._memories, this._photos);

  final MemoriesGateway _memories;
  final PhotoGateway _photos;

  Future<void> call(String sessionId, String photoId) async {
    final memory = _memories.current.memoryOf(sessionId);
    await _memories.save(
      _memories.current.withMemory(
        memory.copyWith(
          photoIds: memory.photoIds.where((p) => p != photoId).toList(),
        ),
      ),
    );
    await _photos.delete(photoId);
  }
}
