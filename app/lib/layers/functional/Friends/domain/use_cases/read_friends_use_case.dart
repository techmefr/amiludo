import 'package:amiludo/layers/functional/Friends/domain/entities/friend_circle.dart';
import 'package:amiludo/layers/functional/Friends/domain/gateways/friends_gateway.dart';

class ReadFriendsUseCase {
  ReadFriendsUseCase(this._friends);

  final FriendsGateway _friends;

  FriendCircle call() => _friends.current;
}
