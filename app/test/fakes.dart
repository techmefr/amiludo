import 'dart:async';
import 'dart:typed_data';

import 'package:amiludo/layers/functional/Memories/domain/gateways/photo_gateway.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class MemoryWorkspace implements WorkspaceGateway {
  MemoryWorkspace([this.current = const Workspace()]);

  @override
  Workspace current;

  final _changes = StreamController<Workspace>.broadcast();

  @override
  Stream<Workspace> get changes => _changes.stream;

  @override
  Stream<bool> get saveFailures => const Stream.empty();

  @override
  Future<Workspace> load() async => current;

  @override
  Future<void> save(Workspace workspace) async {
    current = workspace;
    _changes.add(workspace);
  }
}

class MemoryPhotos implements PhotoGateway {
  final stored = <String, Uint8List>{};

  @override
  Future<Uint8List?> read(String id) async => stored[id];

  @override
  Future<void> write(String id, List<int> bytes) async =>
      stored[id] = Uint8List.fromList(bytes);

  @override
  Future<void> delete(String id) async => stored.remove(id);
}
