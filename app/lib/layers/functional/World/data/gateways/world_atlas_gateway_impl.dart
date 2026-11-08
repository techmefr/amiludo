import 'package:amiludo/layers/functional/World/domain/entities/world_atlas.dart';
import 'package:amiludo/layers/functional/World/domain/gateways/world_atlas_gateway.dart';
import 'package:amiludo/layers/technical/Storage/stored_document.dart';

class WorldAtlasGatewayImpl extends StoredDocument<WorldAtlas>
    implements WorldAtlasGateway {
  WorldAtlasGatewayImpl(super.store)
    : super(
        id: 'worldatlas',
        empty: const WorldAtlas(),
        fromJson: _decode,
        toJson: (atlas) => {'worldAtlas': atlas.toJson()},
      );

  static WorldAtlas _decode(Map<String, dynamic> json) {
    final stored = json['worldAtlas'];
    if (stored is! Map) return const WorldAtlas();
    return WorldAtlas.fromJson(Map<String, dynamic>.from(stored));
  }

  @override
  Map<String, Object?> backup() => current.isEmpty ? const {} : super.backup();
}
