import 'package:amiludo/layers/functional/Timer/domain/entities/game_clock.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class ConfigureClockUseCase {
  ConfigureClockUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(
    int seconds,
    int increment,
    bool bank,
    Iterable<String> playerIds,
  ) {
    final data = _workspace.current;
    return _workspace.save(
      data.copyWith(
        clock: GameClock(
          remainingMs: seconds * 1000,
          durationMs: seconds * 1000,
          incrementMs: increment * 1000,
        ),
        bankMode: bank,
        banks: {for (final id in playerIds) id: seconds * 1000},
      ),
    );
  }
}
