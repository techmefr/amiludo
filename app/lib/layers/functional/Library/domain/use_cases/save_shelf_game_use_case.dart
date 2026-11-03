import 'package:amiludo/layers/functional/Library/domain/entities/shelf.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/library_gateway.dart';

class SaveShelfGameUseCase {
  SaveShelfGameUseCase(this._library);

  final LibraryGateway _library;

  Future<void> call(ShelfGame game) => _library.save(
    Shelf(
      games: [game, ..._library.current.games.where((g) => g.id != game.id)],
    ),
  );
}
