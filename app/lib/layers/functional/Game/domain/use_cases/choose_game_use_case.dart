import 'package:amiludo/layers/functional/Timer/domain/entities/game_clock.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class ChooseGameUseCase {
  ChooseGameUseCase(this._workspace, this._time);

  final WorkspaceGateway _workspace;
  final MonotonicTime _time;

  Future<void> call(String id) {
    final data = _workspace.current;
    if (!data.games.any((g) => g.id == id)) {
      throw ArgumentError('Partie inconnue');
    }
    final snapshots = data.clocksAt(_time.now);
    final saved = snapshots[id];
    return _workspace.save(
      data.copyWith(
        currentId: id,
        sessionClocks: snapshots,
        clock: saved?.clock ?? const GameClock(),
        bankMode: saved?.bankMode ?? false,
        reverse: saved?.reverse ?? false,
      ),
    );
  }
}
