import 'package:amiludo/layers/functional/Library/domain/entities/barcode_product.dart';

class BarcodeLookupFailure implements Exception {
  const BarcodeLookupFailure();
}

abstract class BarcodeLookupGateway {
  Future<BarcodeProduct?> lookup(String code);
}
