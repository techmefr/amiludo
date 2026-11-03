import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Memories/domain/entities/game_memory.dart';
import 'package:amiludo/layers/functional/Memories/domain/entities/memory_album.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/add_photo_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/export_gallery_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/import_gallery_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/read_album_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/read_photo_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/remove_photo_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/save_memory_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/watch_album_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/read_workspace_use_case.dart';

class MemoriesCubit extends Cubit<MemoryAlbum> {
  MemoriesCubit(
    ReadAlbumUseCase readAlbum,
    WatchAlbumUseCase watchAlbum,
    this._readWorkspace,
    this._saveMemory,
    this._addPhoto,
    this._removePhoto,
    this._readPhoto,
    this._exportGallery,
    this._importGallery,
  ) : super(readAlbum()) {
    _subscription = watchAlbum().listen(emit);
  }

  final ReadWorkspaceUseCase _readWorkspace;
  final SaveMemoryUseCase _saveMemory;
  final AddPhotoUseCase _addPhoto;
  final RemovePhotoUseCase _removePhoto;
  final ReadPhotoUseCase _readPhoto;
  final ExportGalleryUseCase _exportGallery;
  final ImportGalleryUseCase _importGallery;
  late final StreamSubscription<MemoryAlbum> _subscription;

  GameSession? session(String id) =>
      _readWorkspace().games.where((g) => g.id == id).firstOrNull;

  Future<void> save(GameMemory memory) => _saveMemory(memory);

  Future<void> addPhoto(String sessionId, List<int> bytes) =>
      _addPhoto(sessionId, bytes);

  Future<void> removePhoto(String sessionId, String photoId) =>
      _removePhoto(sessionId, photoId);

  Future<Uint8List?> readPhoto(String id) => _readPhoto(id);

  Future<GalleryExport> exportGallery(String sessionId) =>
      _exportGallery(sessionId, state.memoryOf(sessionId).photoIds);

  Future<String> importGallery(String fileText, String key) =>
      _importGallery(fileText, key);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
