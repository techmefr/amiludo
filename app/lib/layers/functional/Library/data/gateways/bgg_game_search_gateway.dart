import 'package:amiludo/layers/functional/Library/domain/entities/barcode_product.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/barcode_lookup_gateway.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/imported_game.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/collection_import_gateway.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/game_search_gateway.dart';
import 'package:amiludo/layers/technical/Barcode/bgg_client.dart';
import 'package:amiludo/layers/technical/Barcode/product_lookup.dart';

class BggGameSearchGateway
    implements GameSearchGateway, CollectionImportGateway {
  BggGameSearchGateway(this._client);

  final BggClient _client;

  @override
  bool get available => _client.configured;

  @override
  Future<List<BarcodeProduct>> search(String name) async {
    try {
      final hits = await _client.search(name);
      return [for (final h in hits) BarcodeProduct(title: h.title)];
    } on ProductLookupException {
      throw const BarcodeLookupFailure();
    }
  }

  @override
  Future<List<ImportedGame>> collection(String username) async {
    try {
      final items = await _client.collection(username);
      return [
        for (final i in items)
          ImportedGame(
            name: i.name,
            imageUrl: i.imageUrl,
            minPlayers: i.minPlayers,
            maxPlayers: i.maxPlayers,
            minutes: i.minutes,
          ),
      ];
    } on ProductLookupException {
      throw const BarcodeLookupFailure();
    }
  }
}
