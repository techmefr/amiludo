import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_companion/layers/technical/Storage/store_database.dart';
import 'package:table_companion/layers/functional/Workspace/workspace_controller.dart';
import 'package:table_companion/layers/functional/Templates/domain/game_template.dart';

void main() {
  test('SQLite upserts documents without losing neighboring records', () async {
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    await db.writeDocument('one', 'old');
    await db.writeDocument('two', 'keep');
    await db.writeDocument('one', 'new');
    expect(await db.readDocument('one'), 'new');
    expect(await db.readDocument('two'), 'keep');
    expect(await db.readDocument('missing'), isNull);
    await db.close();
  });
  test('rapid edits serialize writes and survive a fresh controller', () async {
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    await container.read(workspaceProvider.future);
    final controller = container.read(workspaceProvider.notifier);
    await controller.startGame('Test', ['A', 'B'], GameTemplate.builtIn.first);
    final id = controller.data.current!.players.first.id;
    final first = controller.score(id, 1, 'Points');
    final second = controller.score(id, 5, 'Points');
    await Future.wait([first, second]);
    expect(controller.data.current!.score(id), 6);
    container.invalidate(workspaceProvider);
    final restored = await container.read(workspaceProvider.future);
    expect(restored.current!.score(id), 6);
    expect(restored.current!.cursor, 2);
    container.dispose();
    await db.close();
  });
  test(
    'each table keeps its own clock settings and switching pauses it',
    () async {
      final db = StoreDatabase.forTesting(NativeDatabase.memory());
      final c = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      await c.read(workspaceProvider.future);
      final ctrl = c.read(workspaceProvider.notifier);
      await ctrl.startGame('First', ['A', 'B'], GameTemplate.builtIn.first);
      final first = ctrl.data.currentId!;
      await ctrl.configureClock(120, 3, true);
      await ctrl.startGame('Second', ['C', 'D'], GameTemplate.builtIn.first);
      final second = ctrl.data.currentId!;
      await ctrl.configureClock(60, 0, false);
      await ctrl.chooseGame(first);
      expect(ctrl.data.clock.durationMs, 120000);
      expect(ctrl.data.clock.incrementMs, 3000);
      expect(ctrl.data.bankMode, isTrue);
      await ctrl.chooseGame(second);
      expect(ctrl.data.clock.durationMs, 60000);
      expect(ctrl.data.bankMode, isFalse);
      await ctrl.deleteGame(first);
      expect(ctrl.data.currentId, second);
      expect(ctrl.data.clock.durationMs, 60000);
      c.dispose();
      await db.close();
    },
  );
}
