import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Friends/domain/entities/friend.dart';
import 'package:amiludo/layers/functional/Friends/domain/entities/friend_circle.dart';
import 'package:amiludo/layers/functional/Friends/domain/entities/game_review.dart';
import 'package:amiludo/layers/functional/Friends/domain/use_cases/read_friends_use_case.dart';
import 'package:amiludo/layers/functional/Friends/domain/use_cases/remove_friend_use_case.dart';
import 'package:amiludo/layers/functional/Friends/domain/use_cases/save_friend_use_case.dart';
import 'package:amiludo/layers/functional/Friends/domain/use_cases/save_reviews_use_case.dart';
import 'package:amiludo/layers/functional/Friends/domain/use_cases/watch_friends_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/read_workspace_use_case.dart';

class FriendsCubit extends Cubit<FriendCircle> {
  FriendsCubit(
    ReadFriendsUseCase readFriends,
    WatchFriendsUseCase watchFriends,
    this._readWorkspace,
    this._saveFriend,
    this._removeFriend,
    this._saveReviews,
  ) : super(readFriends()) {
    _subscription = watchFriends().listen(emit);
  }

  final ReadWorkspaceUseCase _readWorkspace;
  final SaveFriendUseCase _saveFriend;
  final RemoveFriendUseCase _removeFriend;
  final SaveReviewsUseCase _saveReviews;
  late final StreamSubscription<FriendCircle> _subscription;

  List<ShelfGame> get shelf => _readWorkspace().shelf;

  GameSession? session(String id) =>
      _readWorkspace().games.where((g) => g.id == id).firstOrNull;

  Future<void> save(Friend friend) => _saveFriend(friend);

  Future<void> remove(String id) => _removeFriend(id);

  Future<void> saveReviews(String sessionId, List<GameReview> reviews) =>
      _saveReviews(sessionId, reviews);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
