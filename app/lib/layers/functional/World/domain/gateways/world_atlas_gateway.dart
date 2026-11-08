import 'package:amiludo/layers/functional/World/domain/entities/world_atlas.dart';

abstract class WorldAtlasGateway {
  WorldAtlas get current;
  Stream<WorldAtlas> get changes;
  Future<void> save(WorldAtlas atlas);
}
