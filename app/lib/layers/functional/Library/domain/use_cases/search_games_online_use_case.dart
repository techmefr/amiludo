import 'package:amiludo/layers/functional/Library/domain/entities/barcode_product.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/game_search_gateway.dart';

class SearchGamesOnlineUseCase {
  SearchGamesOnlineUseCase(this._search);

  final GameSearchGateway _search;

  bool get available => _search.available;

  Future<List<BarcodeProduct>> call(String name) async {
    final query = name.trim();
    if (query.length < 2 || !available) return const [];
    try {
      return await _search.search(query);
    } on GameSearchFailure {
      return const [];
    }
  }
}
