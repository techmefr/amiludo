import 'package:amiludo/layers/functional/Friends/domain/entities/friend_circle.dart';
import 'package:amiludo/layers/functional/Friends/domain/gateways/friends_gateway.dart';

class WatchFriendsUseCase {
  WatchFriendsUseCase(this._friends);

  final FriendsGateway _friends;

  Stream<FriendCircle> call() => _friends.changes;
}
