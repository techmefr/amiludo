import 'package:amiludo/layers/functional/Memories/domain/gateways/photo_gateway.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class RemovePhotoUseCase {
  RemovePhotoUseCase(this._workspace, this._photos);

  final WorkspaceGateway _workspace;
  final PhotoGateway _photos;

  Future<void> call(String sessionId, String photoId) async {
    final memory = _workspace.current.memoryOf(sessionId);
    await _workspace.save(
      _workspace.current.withMemory(
        memory.copyWith(
          photoIds: memory.photoIds.where((p) => p != photoId).toList(),
        ),
      ),
    );
    await _photos.delete(photoId);
  }
}
