import 'package:amiludo/layers/functional/Friends/domain/gateways/friends_gateway.dart';

class RemoveFriendUseCase {
  RemoveFriendUseCase(this._friends);

  final FriendsGateway _friends;

  Future<void> call(String id) {
    final circle = _friends.current;
    return _friends.save(
      circle.copyWith(
        friends: circle.friends.where((f) => f.id != id).toList(),
      ),
    );
  }
}
