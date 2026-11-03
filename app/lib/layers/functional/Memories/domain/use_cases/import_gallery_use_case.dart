import 'dart:convert';

import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Memories/domain/entities/game_memory.dart';
import 'package:amiludo/layers/functional/Memories/domain/gateways/memories_gateway.dart';
import 'package:amiludo/layers/functional/Memories/domain/gateways/photo_gateway.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/export_gallery_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';
import 'package:amiludo/layers/technical/Transfer/compression.dart';
import 'package:amiludo/layers/technical/Transfer/sealed_box.dart';

class ImportGalleryUseCase {
  ImportGalleryUseCase(this._workspace, this._memories, this._photos);

  final WorkspaceGateway _workspace;
  final MemoriesGateway _memories;
  final PhotoGateway _photos;

  Future<String> call(String fileText, String key) async {
    final file = Map<String, dynamic>.from(jsonDecode(fileText) as Map);
    if (file['format'] != galleryFormat || file['version'] != 1) {
      throw const FormatException('Ce fichier n’est pas une galerie amiLudo.');
    }
    final content = Map<String, dynamic>.from(
      unpackJson(await SealedBox.open(file, key), maxBytes: 400000000) as Map,
    );
    final game = GameSession.fromJson(
      Map<String, dynamic>.from(content['game'] as Map),
    );
    final received = GameMemory.fromJson(
      Map<String, dynamic>.from(content['memory'] as Map),
    );
    final photos = Map<String, dynamic>.from(content['photos'] as Map);
    for (final entry in photos.entries) {
      await _photos.write(entry.key, base64Decode(entry.value as String));
    }
    final data = _workspace.current;
    final known = data.games.any((g) => g.id == game.id);
    if (!known) {
      await _workspace.save(data.copyWith(games: [...data.games, game]));
    }
    final album = _memories.current;
    await _memories.save(
      album.withMemory(album.memoryOf(game.id).merge(received)),
    );
    return game.id;
  }
}
