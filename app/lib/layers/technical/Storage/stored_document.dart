import 'dart:async';

import 'package:amiludo/layers/technical/Storage/backup_section.dart';
import 'package:amiludo/layers/technical/Storage/document_store.dart';

class StoredDocument<T> implements BackupSection {
  StoredDocument(
    this._store, {
    required this.id,
    required T empty,
    required this.fromJson,
    required this.toJson,
    this.legacyId = 'workspace',
  }) : _current = empty;

  final String id, legacyId;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, Object?> Function(T) toJson;
  final DocumentStore _store;
  final _changes = StreamController<T>.broadcast(sync: true);
  T _current;

  T get current => _current;

  Stream<T> get changes => _changes.stream;

  Future<void> save(T value) {
    _publish(value);
    return _store.write(id, toJson(value));
  }

  @override
  Future<void> load() async {
    final stored = await _store.read(id);
    if (stored != null) return _publish(fromJson(stored));
    final legacy = await _store.read(legacyId);
    if (legacy == null) return;
    final migrated = fromJson(legacy);
    await _store.writeNow(id, toJson(migrated));
    _publish(migrated);
  }

  @override
  Map<String, Object?> backup() => toJson(_current);

  @override
  Future<void> Function() restore(Map<String, dynamic> backup) {
    final value = fromJson(backup);
    return () => save(value);
  }

  void _publish(T value) {
    _current = value;
    _changes.add(value);
  }
}
