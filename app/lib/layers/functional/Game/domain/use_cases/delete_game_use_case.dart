import 'package:amiludo/layers/functional/Timer/domain/entities/game_clock.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class DeleteGameUseCase {
  DeleteGameUseCase(this._workspace, this._time);

  final WorkspaceGateway _workspace;
  final MonotonicTime _time;

  Future<void> call(String id) {
    final data = _workspace.current;
    final clocks = {...data.clocksAt(_time.now)}..remove(id);
    return _workspace.save(
      Workspace(
        appearance: data.appearance,
        profiles: data.profiles,
        games: data.games.where((g) => g.id != id).toList(),
        templates: data.templates,
        characters: data.characters,
        playerNames: data.playerNames,
        favorites: data.favorites,
        currentId: data.currentId == id ? null : data.currentId,
        clock: data.currentId == id ? const GameClock() : data.clock,
        banks: data.banks,
        sessionClocks: clocks,
        bankMode: data.bankMode,
        reverse: data.reverse,
      ),
    );
  }
}
