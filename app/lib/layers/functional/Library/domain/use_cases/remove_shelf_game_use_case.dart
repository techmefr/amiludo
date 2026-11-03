import 'package:amiludo/layers/functional/Friends/domain/entities/friend.dart';
import 'package:amiludo/layers/functional/Friends/domain/gateways/friends_gateway.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/library_gateway.dart';

class RemoveShelfGameUseCase {
  RemoveShelfGameUseCase(this._library, this._friends);

  final LibraryGateway _library;
  final FriendsGateway _friends;

  Future<void> call(String id) async {
    final circle = _friends.current;
    await _library.save(
      Shelf(games: _library.current.games.where((g) => g.id != id).toList()),
    );
    await _friends.save(
      circle.copyWith(
        friends: [
          for (final f in circle.friends)
            f.withOpinion(id, GameOpinion.neutral),
        ],
      ),
    );
  }
}
