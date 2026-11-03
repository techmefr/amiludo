import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Templates/domain/gateways/pack_catalog_gateway.dart';

class FetchPackCatalogUseCase {
  FetchPackCatalogUseCase(this._catalog);

  final PackCatalogGateway _catalog;

  Future<List<GameTemplate>> call() => _catalog.fetch();
}
