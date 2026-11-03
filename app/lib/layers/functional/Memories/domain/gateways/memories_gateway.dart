import 'package:amiludo/layers/functional/Memories/domain/entities/memory_album.dart';

abstract class MemoriesGateway {
  MemoryAlbum get current;
  Stream<MemoryAlbum> get changes;
  Future<void> save(MemoryAlbum album);
}
