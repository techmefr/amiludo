import 'package:amiludo/layers/functional/Friends/domain/entities/friend.dart';
import 'package:amiludo/layers/functional/Friends/domain/gateways/friends_gateway.dart';

class SaveFriendUseCase {
  SaveFriendUseCase(this._friends);

  final FriendsGateway _friends;

  Future<void> call(Friend friend) {
    final circle = _friends.current;
    final duplicate = circle.friends.any(
      (f) =>
          f.id != friend.id &&
          f.name.toLowerCase() == friend.name.trim().toLowerCase(),
    );
    if (duplicate) throw const FormatException('Cet ami existe déjà.');
    return _friends.save(
      circle.copyWith(
        friends: [
          ...circle.friends.where((f) => f.id != friend.id),
          friend,
        ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
      ),
    );
  }
}
