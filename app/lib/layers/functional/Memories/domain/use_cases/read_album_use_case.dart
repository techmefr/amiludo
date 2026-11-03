import 'package:amiludo/layers/functional/Memories/domain/entities/memory_album.dart';
import 'package:amiludo/layers/functional/Memories/domain/gateways/memories_gateway.dart';

class ReadAlbumUseCase {
  ReadAlbumUseCase(this._memories);

  final MemoriesGateway _memories;

  MemoryAlbum call() => _memories.current;
}
