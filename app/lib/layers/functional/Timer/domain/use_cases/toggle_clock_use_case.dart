import 'package:amiludo/layers/functional/Timer/domain/entities/game_clock.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class ToggleClockUseCase {
  ToggleClockUseCase(this._workspace, this._time);

  final WorkspaceGateway _workspace;
  final MonotonicTime _time;

  Future<void> call() {
    final data = _workspace.current;
    return _workspace.save(
      data.copyWith(
        clock: data.clock.isRunning
            ? data.clock.pause(_time.now)
            : data.clock.start(_time.now),
      ),
    );
  }
}
