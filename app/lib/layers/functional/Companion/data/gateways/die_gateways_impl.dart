import 'dart:convert';
import 'dart:typed_data';

import 'package:amiludo/layers/functional/Companion/domain/entities/die_library.dart';
import 'package:amiludo/layers/functional/Companion/domain/gateways/die_gateways.dart';
import 'package:amiludo/layers/technical/Storage/stored_document.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart' show StoreDatabase;

class DieLibraryGatewayImpl extends StoredDocument<DieLibrary>
    implements DieLibraryGateway {
  DieLibraryGatewayImpl(super.store)
    : super(
        id: 'die_library',
        empty: const DieLibrary(),
        fromJson: DieLibrary.fromJson,
        toJson: (library) => library.toJson(),
      );

  @override
  Map<String, Object?> backup() => const {};

  @override
  Future<void> Function() restore(Map<String, dynamic> backup) => () async {};
}

class DieImageGatewayImpl implements DieImageGateway {
  DieImageGatewayImpl(this._database);

  final StoreDatabase _database;
  final _cache = <String, Uint8List>{};

  String _key(String id) => 'dieimg:$id';

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
