import 'package:amiludo/layers/functional/Library/domain/entities/barcode_product.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/barcode_lookup_gateway.dart';
import 'package:amiludo/layers/technical/Barcode/product_lookup.dart';
import 'package:amiludo/layers/technical/Barcode/upc_item_db_client.dart';

class UpcItemDbLookupGateway implements BarcodeLookupGateway {
  UpcItemDbLookupGateway(this._client);

  final UpcItemDbClient _client;

  @override
  Future<BarcodeProduct?> lookup(String code) async {
    try {
      final hit = await _client.lookup(code);
      return hit == null
          ? null
          : BarcodeProduct(title: hit.title, imageUrl: hit.imageUrl);
    } on ProductLookupException {
      throw const BarcodeLookupFailure();
    }
  }
}
