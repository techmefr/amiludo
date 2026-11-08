import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Friends/domain/entities/friend_circle.dart';
import 'package:amiludo/layers/functional/Friends/domain/use_cases/read_friends_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/library_stats.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Library/domain/use_cases/read_shelf_use_case.dart';
import 'package:amiludo/layers/functional/Library/domain/use_cases/remove_shelf_game_use_case.dart';
import 'package:amiludo/layers/functional/Library/domain/use_cases/save_shelf_game_use_case.dart';
import 'package:amiludo/layers/functional/Library/domain/use_cases/suggest_games_use_case.dart';
import 'package:amiludo/layers/functional/Library/domain/use_cases/watch_shelf_use_case.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/read_workspace_use_case.dart';

class LibraryCubit extends Cubit<Shelf> {
  LibraryCubit(
    ReadShelfUseCase readShelf,
    WatchShelfUseCase watchShelf,
    this._saveGame,
    this._removeGame,
    this._suggestGames,
    this._readFriends,
    this._readWorkspace,
  ) : super(readShelf()) {
    _subscription = watchShelf().listen(emit);
  }

  final SaveShelfGameUseCase _saveGame;
  final RemoveShelfGameUseCase _removeGame;
  final SuggestGamesUseCase _suggestGames;
  final ReadFriendsUseCase _readFriends;
  final ReadWorkspaceUseCase _readWorkspace;
  late final StreamSubscription<Shelf> _subscription;

  FriendCircle get circle => _readFriends();

  List<GameTemplate> get templates => _readWorkspace().templates;

  List<GameSession> get sessions => _readWorkspace().games;

  LibraryStats statsFor(Shelf shelf) => LibraryStats.of(shelf.games, [
    for (final g in sessions) (title: g.title, packId: g.pack?.id),
  ]);

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
