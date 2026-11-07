import 'dart:convert';
import 'dart:typed_data';

import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook.dart';
import 'package:amiludo/layers/functional/Notebook/domain/gateways/notebook_gateways.dart';
import 'package:amiludo/layers/technical/Storage/stored_document.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart'
    show StoreDatabase;

class NotebookGatewayImpl extends StoredDocument<Notebook>
    implements NotebookGateway {
  NotebookGatewayImpl(super.store)
    : super(
        id: 'notebook',
        empty: const Notebook(),
        fromJson: Notebook.fromJson,
        toJson: (notebook) => notebook.toJson(),
        legacyId: 'notebook-legacy',
      );

  @override
  Map<String, Object?> backup() => current.isEmpty ? const {} : super.backup();
}

class NotebookImageGatewayImpl implements NotebookImageGateway {
  NotebookImageGatewayImpl(this._database);

  final StoreDatabase _database;
  final _cache = <String, Uint8List>{};

  String _key(String id) => 'nbimg:$id';

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
