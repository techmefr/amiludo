import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';

abstract class PackCatalogGateway {
  Future<List<GameTemplate>> bundled();
  Future<List<GameTemplate>> fetch();
}
