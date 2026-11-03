import 'package:amiludo/layers/functional/Memories/domain/entities/memory_album.dart';
import 'package:amiludo/layers/functional/Memories/domain/gateways/memories_gateway.dart';
import 'package:amiludo/layers/technical/Storage/stored_document.dart';

class MemoriesGatewayImpl extends StoredDocument<MemoryAlbum>
    implements MemoriesGateway {
  MemoriesGatewayImpl(super.store)
    : super(
        id: 'memories',
        empty: const MemoryAlbum(),
        fromJson: MemoryAlbum.fromJson,
        toJson: (album) => album.toJson(),
      );
}
