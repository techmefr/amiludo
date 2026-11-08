import 'package:amiludo/layers/functional/Library/domain/entities/barcode_product.dart';

abstract class BarcodeCacheGateway {
  Future<BarcodeProduct?> read(String code);
  Future<void> write(String code, BarcodeProduct product);
}
