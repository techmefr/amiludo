import 'package:amiludo/layers/functional/Timer/domain/entities/game_clock.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class FinishGameUseCase {
  FinishGameUseCase(this._workspace, this._time);

  final WorkspaceGateway _workspace;
  final MonotonicTime _time;

  Future<void> call() async {
    final data = _workspace.current;
    await _workspace.save(
      data.withGame(
        data.current!.copyWith(
          finishedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      ),
    );
    final finished = _workspace.current;
    await _workspace.save(
      finished.copyWith(clock: finished.clock.pause(_time.now)),
    );
  }
}
