import 'package:amiludo/layers/functional/Library/domain/entities/barcode_product.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';

class BarcodeMatch {
  const BarcodeMatch(
    this.code, {
    this.owned,
    this.product,
    this.unreachable = false,
  });

  final String code;
  final ShelfGame? owned;
  final BarcodeProduct? product;
  final bool unreachable;
}

String barcodeDigits(String raw) => raw.replaceAll(RegExp(r'\D'), '');

bool isValidBarcode(String digits) => digits.length >= 8 && digits.length <= 14;
