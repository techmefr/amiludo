import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/add_score_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/finish_game_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/next_round_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/redo_score_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/reverse_turn_order_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/save_game_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/set_resource_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/set_status_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/undo_score_use_case.dart';
import 'package:amiludo/layers/functional/Timer/domain/use_cases/next_turn_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/read_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/watch_workspace_use_case.dart';

class GameCubit extends Cubit<Workspace> {
  GameCubit(
    ReadWorkspaceUseCase readWorkspace,
    WatchWorkspaceUseCase watchWorkspace,
    this._addScore,
    this._undoScore,
    this._redoScore,
    this._nextRound,
    this._saveGame,
    this._finishGame,
    this._reverseTurnOrder,
    this._nextTurn,
    this._setResource,
    this._setStatus,
  ) : super(readWorkspace()) {
    _subscription = watchWorkspace().listen(emit);
  }

  final AddScoreUseCase _addScore;
  final UndoScoreUseCase _undoScore;
  final RedoScoreUseCase _redoScore;
  final NextRoundUseCase _nextRound;
  final SaveGameUseCase _saveGame;
  final FinishGameUseCase _finishGame;
  final ReverseTurnOrderUseCase _reverseTurnOrder;
  final NextTurnUseCase _nextTurn;
  final SetResourceUseCase _setResource;
  final SetStatusUseCase _setStatus;
  late final StreamSubscription<Workspace> _subscription;

  Future<void> score(String player, double value, String category) =>
      _addScore(player, value, category);

  Future<void> undo() => _undoScore();

  Future<void> redo() => _redoScore();

  Future<void> nextRound() => _nextRound();

  Future<void> saveGame(GameSession game) => _saveGame(game);

  Future<void> finish() => _finishGame();

  Future<void> reverseTurnOrder() => _reverseTurnOrder();

  Future<void> nextTurn() => _nextTurn();

  Future<void> setResource(String player, String key, double value) =>
      _setResource(player, key, value);

  Future<void> setStatus(String player, String status, int stacks) =>
      _setStatus(player, status, stacks);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
