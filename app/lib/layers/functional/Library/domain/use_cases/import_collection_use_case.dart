import 'dart:math';

import 'package:amiludo/layers/functional/Library/domain/entities/imported_game.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/collection_import_gateway.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/library_gateway.dart';

class ImportCollectionUseCase {
  ImportCollectionUseCase(this._library, this._source);

  final LibraryGateway _library;
  final CollectionImportGateway _source;

  bool get available => _source.available;

  Future<int> call(String username) async {
    final name = username.trim();
    if (name.isEmpty || !available) return 0;
    final imported = await _source.collection(name);
    final known = {
      for (final g in _library.current.games) g.name.toLowerCase(),
    };
    final fresh = <ShelfGame>[];
    for (final game in imported) {
      final title = game.name.trim();
      if (title.isEmpty || title.length > 80) continue;
      if (!known.add(title.toLowerCase())) continue;
      fresh.add(_shelved(game, title, fresh.length));
    }
    if (fresh.isEmpty) return 0;
    await _library.save(Shelf(games: [...fresh, ..._library.current.games]));
    return fresh.length;
  }

  ShelfGame _shelved(ImportedGame game, String title, int index) {
    final minPlayers = game.minPlayers > 0 ? min(game.minPlayers, 100) : 2;
    return ShelfGame(
      id: 'bgg-${title.toLowerCase().hashCode}',
      name: title,
      imageUrl: game.imageUrl.startsWith('https://') ? game.imageUrl : '',
      minPlayers: minPlayers,
      maxPlayers: max(minPlayers, min(game.maxPlayers, 100)),
      minutes: game.minutes > 0 ? game.minutes.clamp(1, 6000) : 45,
      color: shelfColors[index % shelfColors.length],
      addedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
