import 'dart:convert';

import 'package:amiludo/layers/functional/Memories/domain/gateways/memories_gateway.dart';
import 'package:amiludo/layers/functional/Memories/domain/gateways/photo_gateway.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';
import 'package:amiludo/layers/technical/Transfer/compression.dart';
import 'package:amiludo/layers/technical/Transfer/sealed_box.dart';

const galleryFormat = 'amiludo-gallery';

class GalleryExport {
  const GalleryExport(this.fileText, this.key, this.filename);

  final String fileText, key, filename;
}

class ExportGalleryUseCase {
  ExportGalleryUseCase(this._workspace, this._memories, this._photos);

  final WorkspaceGateway _workspace;
  final MemoriesGateway _memories;
  final PhotoGateway _photos;

  Future<GalleryExport> call(String sessionId, List<String> photoIds) async {
    final game = _workspace.current.games.firstWhere((g) => g.id == sessionId);
    final memory = _memories.current.memoryOf(sessionId);
    final photos = <String, String>{};
    for (final id in photoIds.where(memory.photoIds.contains)) {
      final bytes = await _photos.read(id);
      if (bytes != null) photos[id] = base64Encode(bytes);
    }
    final key = SealedBox.newKey();
    final sealed = await SealedBox.seal(
      packJson({
        'game': game.toJson(),
        'memory': memory.copyWith(photoIds: photos.keys.toList()).toJson(),
        'photos': photos,
      }),
      key,
    );
    final file = jsonEncode({'format': galleryFormat, 'version': 1, ...sealed});
    return GalleryExport(file, key, 'galerie-${game.id}.json');
  }
}
