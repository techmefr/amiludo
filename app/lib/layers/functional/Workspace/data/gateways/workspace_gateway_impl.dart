import 'dart:async';

import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';
import 'package:amiludo/layers/technical/Storage/document_store.dart';

class WorkspaceGatewayImpl implements WorkspaceGateway {
  WorkspaceGatewayImpl(this._store);

  static const _documentId = 'workspace';

  final DocumentStore _store;
  final _changes = StreamController<Workspace>.broadcast(sync: true);
  Workspace _current = const Workspace();

  @override
  Workspace get current => _current;

  @override
  Stream<Workspace> get changes => _changes.stream;

  @override
  Stream<bool> get saveFailures => _store.failures;

  @override
  Future<Workspace> load() async {
    final stored = await _store.read(_documentId);
    _current = stored == null ? const Workspace() : Workspace.fromJson(stored);
    _changes.add(_current);
    return _current;
  }

  @override
  Future<void> save(Workspace workspace) {
    _current = workspace;
    _changes.add(workspace);
    return _store.write(_documentId, workspace.toJson());
  }

  @override
  Future<void> retrySave() => _store.retry();
}
