import 'package:amiludo/layers/functional/Timer/domain/entities/game_clock.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class SetClockUseCase {
  SetClockUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(GameClock clock) =>
      _workspace.save(_workspace.current.copyWith(clock: clock));
}
