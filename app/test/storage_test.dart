import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/technical/Storage/document_store.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/add_score_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/choose_game_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/delete_game_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/start_game_use_case.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Timer/domain/use_cases/configure_clock_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/data/gateways/workspace_gateway_impl.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

void main() {
  tearDown(getIt.reset);
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
    configureDependencies(db);
    final workspace = getIt<WorkspaceGateway>();
    await workspace.load();
    await getIt<StartGameUseCase>()('Test', [
      'A',
      'B',
    ], GameTemplate.builtIn.first);
    final id = workspace.current.current!.players.first.id;
    final score = getIt<AddScoreUseCase>();
    final first = score(id, 1, 'Points');
    final second = score(id, 5, 'Points');
    await Future.wait([first, second]);
    expect(workspace.current.current!.score(id), 6);
    final restored = await WorkspaceGatewayImpl(DocumentStore(db)).load();
    expect(restored.current!.score(id), 6);
    expect(restored.current!.cursor, 2);
    await db.close();
  });
  test(
    'each table keeps its own clock settings and switching pauses it',
    () async {
      final db = StoreDatabase.forTesting(NativeDatabase.memory());
      configureDependencies(db);
      final workspace = getIt<WorkspaceGateway>();
      await workspace.load();
      final startGame = getIt<StartGameUseCase>(),
          configureClock = getIt<ConfigureClockUseCase>(),
          chooseGame = getIt<ChooseGameUseCase>();
      await startGame('First', ['A', 'B'], GameTemplate.builtIn.first);
      final first = workspace.current.currentId!;
      await configureClock(120, 3, true);
      await startGame('Second', ['C', 'D'], GameTemplate.builtIn.first);
      final second = workspace.current.currentId!;
      await configureClock(60, 0, false);
      await chooseGame(first);
      expect(workspace.current.clock.durationMs, 120000);
      expect(workspace.current.clock.incrementMs, 3000);
      expect(workspace.current.bankMode, isTrue);
      await chooseGame(second);
      expect(workspace.current.clock.durationMs, 60000);
      expect(workspace.current.bankMode, isFalse);
      await getIt<DeleteGameUseCase>()(first);
      expect(workspace.current.currentId, second);
      expect(workspace.current.clock.durationMs, 60000);
      await db.close();
    },
  );
}
