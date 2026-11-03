import 'package:amiludo/layers/functional/Friends/domain/entities/friend_circle.dart';

abstract class FriendsGateway {
  FriendCircle get current;
  Stream<FriendCircle> get changes;
  Future<void> save(FriendCircle circle);
}
