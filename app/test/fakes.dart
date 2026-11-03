import 'dart:async';
import 'dart:typed_data';

import 'package:amiludo/layers/functional/Evenings/domain/entities/evening_agenda.dart';
import 'package:amiludo/layers/functional/Evenings/domain/gateways/evenings_gateway.dart';
import 'package:amiludo/layers/functional/Friends/domain/entities/friend_circle.dart';
import 'package:amiludo/layers/functional/Friends/domain/gateways/friends_gateway.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/library_gateway.dart';
import 'package:amiludo/layers/functional/Memories/domain/entities/memory_album.dart';
import 'package:amiludo/layers/functional/Memories/domain/gateways/memories_gateway.dart';
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

  @override
  Future<void> retrySave() async {}
}

class MemoryFriends implements FriendsGateway {
  MemoryFriends([this.current = const FriendCircle()]);

  @override
  FriendCircle current;

  final _changes = StreamController<FriendCircle>.broadcast();

  @override
  Stream<FriendCircle> get changes => _changes.stream;

  @override
  Future<void> save(FriendCircle circle) async {
    current = circle;
    _changes.add(circle);
  }
}

class MemoryShelf implements LibraryGateway {
  MemoryShelf([this.current = const Shelf()]);

  @override
  Shelf current;

  final _changes = StreamController<Shelf>.broadcast();

  @override
  Stream<Shelf> get changes => _changes.stream;

  @override
  Future<void> save(Shelf shelf) async {
    current = shelf;
    _changes.add(shelf);
  }
}

class MemoryAlbumStore implements MemoriesGateway {
  MemoryAlbumStore([this.current = const MemoryAlbum()]);

  @override
  MemoryAlbum current;

  final _changes = StreamController<MemoryAlbum>.broadcast();

  @override
  Stream<MemoryAlbum> get changes => _changes.stream;

  @override
  Future<void> save(MemoryAlbum album) async {
    current = album;
    _changes.add(album);
  }
}

class MemoryAgenda implements EveningsGateway {
  MemoryAgenda([this.current = const EveningAgenda()]);

  @override
  EveningAgenda current;

  final _changes = StreamController<EveningAgenda>.broadcast();

  @override
  Stream<EveningAgenda> get changes => _changes.stream;

  @override
  Future<void> save(EveningAgenda agenda) async {
    current = agenda;
    _changes.add(agenda);
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
