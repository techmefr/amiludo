import 'dart:async';
import 'dart:convert';

import 'package:amiludo/layers/technical/Storage/store_database.dart';

class DocumentStore {
  DocumentStore(this._database);

  final StoreDatabase _database;
  final _failures = StreamController<bool>.broadcast(sync: true);
  final _unsaved = <String, String>{};
  Future<void> _writes = Future.value();

  Stream<bool> get failures => _failures.stream;

  Future<Map<String, dynamic>?> read(String id) async {
    final raw = await _database.readDocument(id);
    return raw == null
        ? null
        : Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<void> write(String id, Map<String, Object?> json) =>
      _enqueue(id, jsonEncode(json));

  Future<void> writeNow(String id, Map<String, Object?> json) =>
      _database.writeDocument(id, jsonEncode(json));

  Future<void> retry() => Future.wait([
    for (final MapEntry(key: id, value: payload) in {..._unsaved}.entries)
      _enqueue(id, payload),
  ]);

  Future<void> _enqueue(String id, String payload) {
    _writes = _writes
        .then((_) => _database.writeDocument(id, payload))
        .then(
          (_) {
            _unsaved.remove(id);
            _failures.add(_unsaved.isNotEmpty);
          },
          onError: (Object error, StackTrace stack) {
            _unsaved[id] = payload;
            _failures.add(true);
          },
        );
    return _writes;
  }
}
