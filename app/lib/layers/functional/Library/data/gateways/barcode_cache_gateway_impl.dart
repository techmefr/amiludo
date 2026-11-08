import 'package:amiludo/layers/functional/Library/domain/entities/barcode_product.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/barcode_cache_gateway.dart';
import 'package:amiludo/layers/technical/Storage/document_store.dart';

class BarcodeCacheGatewayImpl implements BarcodeCacheGateway {
  BarcodeCacheGatewayImpl(this._store);

  static const _id = 'barcode_cache';

  final DocumentStore _store;
  Map<String, dynamic>? _entries;

  Future<Map<String, dynamic>> _load() async =>
      _entries ??= await _store.read(_id) ?? {};

  @override
  Future<BarcodeProduct?> read(String code) async {
    final entry = (await _load())[code];
    return entry is Map
        ? BarcodeProduct.fromJson(Map<String, dynamic>.from(entry))
        : null;
  }

  @override
  Future<void> write(String code, BarcodeProduct product) async {
    final entries = await _load();
    entries[code] = product.toJson();
    await _store.write(_id, entries);
  }
}
