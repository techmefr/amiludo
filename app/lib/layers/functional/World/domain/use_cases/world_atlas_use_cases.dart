import 'package:amiludo/layers/functional/World/domain/entities/world_atlas.dart';
import 'package:amiludo/layers/functional/World/domain/gateways/world_atlas_gateway.dart';

class ReadWorldAtlasUseCase {
  ReadWorldAtlasUseCase(this._atlas);
  final WorldAtlasGateway _atlas;

  WorldAtlas call() => _atlas.current;
}

class SaveWorldAtlasUseCase {
  SaveWorldAtlasUseCase(this._atlas);
  final WorldAtlasGateway _atlas;

  Future<void> call(WorldAtlas atlas) => _atlas.save(atlas);
}
