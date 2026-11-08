import 'package:amiludo/layers/functional/Library/domain/entities/barcode_product.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/barcode_lookup_gateway.dart';

abstract class GameSearchGateway {
  bool get available;
  Future<List<BarcodeProduct>> search(String name);
}

typedef GameSearchFailure = BarcodeLookupFailure;
