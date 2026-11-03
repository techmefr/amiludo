import 'package:amiludo/layers/functional/Timer/domain/entities/game_clock.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class NextTurnUseCase {
  NextTurnUseCase(this._workspace, this._time);

  final WorkspaceGateway _workspace;
  final MonotonicTime _time;

  Future<void> call() {
    final data = _workspace.current;
    final current = data.current!;
    final next = current.nextTurn(reverse: data.reverse);
    final banks = {...data.banks};
    final remaining =
        data.clock.remainingAt(_time.now) + data.clock.incrementMs;
    banks[current.players[current.activeIndex].id] = remaining;
    final budget = data.bankMode
        ? (banks[next.players[next.activeIndex].id] ?? data.clock.durationMs)
        : data.clock.durationMs;
    final nextClock = GameClock(
      remainingMs: budget,
      durationMs: data.clock.durationMs,
      incrementMs: data.clock.incrementMs,
    );
    return _workspace.save(
      data
          .withGame(next)
          .copyWith(
            banks: banks,
            clock: data.clock.isRunning
                ? nextClock.start(_time.now)
                : nextClock,
          ),
    );
  }
}
