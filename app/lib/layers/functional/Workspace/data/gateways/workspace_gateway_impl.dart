import 'dart:async';
import 'dart:convert';

import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

class WorkspaceGatewayImpl implements WorkspaceGateway {
  WorkspaceGatewayImpl(this._database);

  static const _documentId = 'workspace';

  final StoreDatabase _database;
  final _changes = StreamController<Workspace>.broadcast(sync: true);
  final _saveFailures = StreamController<bool>.broadcast(sync: true);
  Future<void> _writes = Future.value();
  Workspace _current = const Workspace();

  @override
  Workspace get current => _current;

  @override
  Stream<Workspace> get changes => _changes.stream;

  @override
  Stream<bool> get saveFailures => _saveFailures.stream;

  @override
  Future<Workspace> load() async {
    final raw = await _database.readDocument(_documentId);
    _current = raw == null
        ? const Workspace()
        : Workspace.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
    _changes.add(_current);
    return _current;
  }

  @override
  Future<void> save(Workspace workspace) {
    _current = workspace;
    _changes.add(workspace);
    final payload = workspace.export();
    _writes = _writes
        .then((_) => _database.writeDocument(_documentId, payload))
        .then(
          (_) => _saveFailures.add(false),
          onError: (Object error, StackTrace stack) => _saveFailures.add(true),
        );
    return _writes;
  }
}
