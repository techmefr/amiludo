import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/erase_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/load_workspace_use_case.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

void main() {
  tearDown(getIt.reset);

  test('clearAll removes every stored document', () async {
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    await db.writeDocument('one', 'a');
    await db.writeDocument('photo.1', 'b');
    await db.clearAll();
    expect(await db.readDocument('one'), isNull);
    expect(await db.readDocument('photo.1'), isNull);
    await db.close();
  });

  test(
    'erasing all data leaves the database empty and the app fresh',
    () async {
      final db = StoreDatabase.forTesting(NativeDatabase.memory());
      configureDependencies(db);
      await getIt<LoadWorkspaceUseCase>()();
      final workspace = getIt<WorkspaceGateway>();
      await workspace.save(workspace.current.copyWith(nickname: 'Sam'));
      await db.writeDocument('photo.1', 'bytes');
      await db.writeDocument('die.1', 'bytes');
      await getIt<EraseWorkspaceUseCase>()();
      expect(await db.readDocument('workspace'), isNull);
      expect(await db.readDocument('photo.1'), isNull);
      expect(await db.readDocument('die.1'), isNull);
      expect(workspace.current.nickname, isNot('Sam'));
      await db.close();
    },
  );
}
