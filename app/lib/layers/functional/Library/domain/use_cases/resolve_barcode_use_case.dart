import 'package:amiludo/layers/functional/Library/domain/entities/barcode_match.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/barcode_cache_gateway.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/barcode_lookup_gateway.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/library_gateway.dart';

class ResolveBarcodeUseCase {
  ResolveBarcodeUseCase(this._library, this._cache, this._lookup);

  final LibraryGateway _library;
  final BarcodeCacheGateway _cache;
  final BarcodeLookupGateway _lookup;

  Future<BarcodeMatch> call(String raw) async {
    final code = barcodeDigits(raw);
    final owned = _library.current.games
        .where((g) => g.barcode == code)
        .firstOrNull;
    if (owned != null) return BarcodeMatch(code, owned: owned);
    final cached = await _cache.read(code);
    if (cached != null) return BarcodeMatch(code, product: cached);
    try {
      final found = await _lookup.lookup(code);
      if (found == null) return BarcodeMatch(code);
      await _cache.write(code, found);
      return BarcodeMatch(code, product: found);
    } on BarcodeLookupFailure {
      return BarcodeMatch(code, unreachable: true);
    }
  }
}
