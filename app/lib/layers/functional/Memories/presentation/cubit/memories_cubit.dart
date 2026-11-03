import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Memories/domain/entities/game_memory.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/add_photo_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/export_gallery_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/import_gallery_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/read_photo_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/remove_photo_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/save_memory_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/read_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/watch_workspace_use_case.dart';

class MemoriesCubit extends Cubit<Workspace> {
  MemoriesCubit(
    ReadWorkspaceUseCase readWorkspace,
    WatchWorkspaceUseCase watchWorkspace,
    this._saveMemory,
    this._addPhoto,
    this._removePhoto,
    this._readPhoto,
    this._exportGallery,
    this._importGallery,
  ) : super(readWorkspace()) {
    _subscription = watchWorkspace().listen(emit);
  }

  final SaveMemoryUseCase _saveMemory;
  final AddPhotoUseCase _addPhoto;
  final RemovePhotoUseCase _removePhoto;
  final ReadPhotoUseCase _readPhoto;
  final ExportGalleryUseCase _exportGallery;
  final ImportGalleryUseCase _importGallery;
  late final StreamSubscription<Workspace> _subscription;

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
