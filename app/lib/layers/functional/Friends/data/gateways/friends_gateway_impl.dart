import 'package:amiludo/layers/functional/Friends/domain/entities/friend_circle.dart';
import 'package:amiludo/layers/functional/Friends/domain/gateways/friends_gateway.dart';
import 'package:amiludo/layers/technical/Storage/stored_document.dart';

class FriendsGatewayImpl extends StoredDocument<FriendCircle>
    implements FriendsGateway {
  FriendsGatewayImpl(super.store)
    : super(
        id: 'friends',
        empty: const FriendCircle(),
        fromJson: FriendCircle.fromJson,
        toJson: (circle) => circle.toJson(),
      );
}
