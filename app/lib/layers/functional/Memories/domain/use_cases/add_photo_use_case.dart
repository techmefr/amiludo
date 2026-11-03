import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Memories/domain/gateways/photo_gateway.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class AddPhotoUseCase {
  AddPhotoUseCase(this._workspace, this._photos);

  static const maxBytes = 8000000;
  static const maxPhotos = 60;

  final WorkspaceGateway _workspace;
  final PhotoGateway _photos;

  Future<void> call(String sessionId, List<int> bytes) async {
    final memory = _workspace.current.memoryOf(sessionId);
    if (bytes.length > maxBytes) {
      throw const FormatException('Photo trop lourde (8 Mo maximum).');
    }
    if (memory.photoIds.length >= maxPhotos) {
      throw const FormatException('60 photos maximum par partie.');
    }
    final id = '$sessionId-${newId()}';
    await _photos.write(id, bytes);
    await _workspace.save(
      _workspace.current.withMemory(
        memory.copyWith(photoIds: [...memory.photoIds, id]),
      ),
    );
  }
}
