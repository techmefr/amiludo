import 'dart:convert';
import 'dart:typed_data';

import 'package:amiludo/layers/functional/Memories/domain/gateways/photo_gateway.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

class PhotoGatewayImpl implements PhotoGateway {
  PhotoGatewayImpl(this._database);

  final StoreDatabase _database;
  final _cache = <String, Uint8List>{};

  String _key(String id) => 'photo:$id';

  @override
  Future<Uint8List?> read(String id) async {
    final cached = _cache[id];
    if (cached != null) return cached;
    final raw = await _database.readDocument(_key(id));
    if (raw == null) return null;
    return _cache[id] = base64Decode(raw);
  }

  @override
  Future<void> write(String id, List<int> bytes) {
    _cache[id] = Uint8List.fromList(bytes);
    return _database.writeDocument(_key(id), base64Encode(bytes));
  }

  @override
  Future<void> delete(String id) {
    _cache.remove(id);
    return _database.deleteDocument(_key(id));
  }
}
