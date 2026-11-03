import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Library/domain/use_cases/remove_shelf_game_use_case.dart';
import 'package:amiludo/layers/functional/Library/domain/use_cases/save_shelf_game_use_case.dart';
import 'package:amiludo/layers/functional/Library/domain/use_cases/suggest_games_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/read_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/watch_workspace_use_case.dart';

class LibraryCubit extends Cubit<Workspace> {
  LibraryCubit(
    ReadWorkspaceUseCase readWorkspace,
    WatchWorkspaceUseCase watchWorkspace,
    this._saveGame,
    this._removeGame,
    this._suggestGames,
  ) : super(readWorkspace()) {
    _subscription = watchWorkspace().listen(emit);
  }

  final SaveShelfGameUseCase _saveGame;
  final RemoveShelfGameUseCase _removeGame;
  final SuggestGamesUseCase _suggestGames;
  late final StreamSubscription<Workspace> _subscription;

  Future<void> save(ShelfGame game) => _saveGame(game);

  Future<void> remove(String id) => _removeGame(id);

  List<GameSuggestion> suggest(List<String> friendIds, {int minutes = 0}) =>
      _suggestGames(friendIds, minutes: minutes);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
