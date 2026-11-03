import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Friends/data/gateways/friends_gateway_impl.dart';
import 'package:amiludo/layers/functional/Friends/domain/gateways/friends_gateway.dart';
import 'package:amiludo/layers/functional/Library/data/gateways/library_gateway_impl.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/library_gateway.dart';
import 'package:amiludo/layers/functional/Memories/data/gateways/memories_gateway_impl.dart';
import 'package:amiludo/layers/functional/Memories/domain/gateways/memories_gateway.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/erase_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/export_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/import_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/load_workspace_use_case.dart';
import 'package:amiludo/layers/technical/Storage/document_store.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

final _legacyBackup = File('test/fixtures/backup_0_4_0.json')
    .readAsStringSync();

Map<String, dynamic> _decode(String text) =>
    Map<String, dynamic>.from(jsonDecode(text) as Map);

Future<StoreDatabase> _open({String? legacyWorkspace}) async {
  final db = StoreDatabase.forTesting(NativeDatabase.memory());
  if (legacyWorkspace != null) {
    await db.writeDocument('workspace', legacyWorkspace);
  }
  configureDependencies(db);
  await getIt<LoadWorkspaceUseCase>()();
  return db;
}

void main() {
  tearDown(getIt.reset);

  test('a 0.4.0 backup imports and exports unchanged', () async {
    final db = await _open();
    await getIt<ImportBackupUseCase>()(_legacyBackup);
    final friends = getIt<FriendsGateway>().current;
    expect(friends.friends.single.name, 'Alex');
    expect(friends.friends.single.wishedGameIds, ['shelf-skull']);
    expect(friends.reviews.single.stars, 4);
    expect(getIt<LibraryGateway>().current.games.single.name, 'Skull');
    expect(_decode(getIt<ExportBackupUseCase>()()), _decode(_legacyBackup));
    await db.close();
  });

  test('a 0.4.0 database moves friends into their own document', () async {
    final db = await _open(legacyWorkspace: _legacyBackup);
    expect(getIt<FriendsGateway>().current.friends.single.name, 'Alex');
    expect(await db.readDocument('friends'), isNotNull);
    final workspace = getIt<WorkspaceGateway>();
    await workspace.save(workspace.current.copyWith(nickname: 'Sam'));
    final stored = _decode((await db.readDocument('workspace'))!);
    expect(stored.containsKey('friends'), isFalse);
    final reopened = FriendsGatewayImpl(DocumentStore(db));
    await reopened.load();
    expect(reopened.current.friends.single.name, 'Alex');
    expect(reopened.current.reviews.single.reviewer, 'Alex');
    await db.close();
  });

  test('a 0.4.0 database moves the shelf into its own document', () async {
    final db = await _open(legacyWorkspace: _legacyBackup);
    expect(getIt<LibraryGateway>().current.games.single.id, 'shelf-skull');
    final workspace = getIt<WorkspaceGateway>();
    await workspace.save(workspace.current.copyWith(nickname: 'Sam'));
    final stored = _decode((await db.readDocument('workspace'))!);
    expect(stored.containsKey('shelf'), isFalse);
    final reopened = LibraryGatewayImpl(DocumentStore(db));
    await reopened.load();
    expect(reopened.current.games.single.name, 'Skull');
    await getIt<EraseWorkspaceUseCase>()();
    expect(getIt<LibraryGateway>().current.games, isEmpty);
    await db.close();
  });

  test('a 0.4.0 database moves memories into their own document', () async {
    final db = await _open(legacyWorkspace: _legacyBackup);
    final sessionId = getIt<WorkspaceGateway>().current.games.single.id;
    expect(
      getIt<MemoriesGateway>().current.memoryOf(sessionId).note,
      'Belle soirée',
    );
    final workspace = getIt<WorkspaceGateway>();
    await workspace.save(workspace.current.copyWith(nickname: 'Sam'));
    final stored = _decode((await db.readDocument('workspace'))!);
    expect(stored.containsKey('memories'), isFalse);
    final reopened = MemoriesGatewayImpl(DocumentStore(db));
    await reopened.load();
    expect(
      reopened.current.memoryOf(sessionId).highlights.single.text,
      'Bluff final',
    );
    await getIt<EraseWorkspaceUseCase>()();
    expect(getIt<MemoriesGateway>().current.memories, isEmpty);
    await db.close();
  });

  test('erasing the workspace also forgets friends', () async {
    final db = await _open(legacyWorkspace: _legacyBackup);
    await getIt<EraseWorkspaceUseCase>()();
    expect(getIt<FriendsGateway>().current.friends, isEmpty);
    expect(getIt<FriendsGateway>().current.reviews, isEmpty);
    expect(_decode(getIt<ExportBackupUseCase>()())['friends'], isEmpty);
    await db.close();
  });

  test(
    'an invalid friend aborts the import before anything is written',
    () async {
      final db = await _open(legacyWorkspace: _legacyBackup);
      final broken = _decode(_legacyBackup)
        ..['friends'] = [
          {'id': 'x', 'name': ' '},
        ]
        ..['nickname'] = 'Changed';
      await expectLater(
        getIt<ImportBackupUseCase>()(jsonEncode(broken)),
        throwsFormatException,
      );
      expect(getIt<FriendsGateway>().current.friends.single.name, 'Alex');
      expect(getIt<WorkspaceGateway>().current.nickname, 'Gaëtan');
      await db.close();
    },
  );
}
