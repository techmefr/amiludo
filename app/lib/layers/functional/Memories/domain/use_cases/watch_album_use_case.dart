import 'package:amiludo/layers/functional/Memories/domain/entities/memory_album.dart';
import 'package:amiludo/layers/functional/Memories/domain/gateways/memories_gateway.dart';

class WatchAlbumUseCase {
  WatchAlbumUseCase(this._memories);

  final MemoriesGateway _memories;

  Stream<MemoryAlbum> call() => _memories.changes;
}
