import 'package:http/http.dart' as http;

import 'package:amiludo/layers/technical/Barcode/bgg_collection.dart';
import 'package:amiludo/layers/technical/Barcode/product_lookup.dart';

class BggClient {
  BggClient({
    http.Client? client,
    this.token = const String.fromEnvironment('BGG_TOKEN'),
    this.retryDelay = const Duration(seconds: 3),
  }) : _client = client ?? http.Client();

  static final _name = RegExp(r'<name[^>]*value="([^"]*)"');
  static const _entities = {
    '&amp;': '&',
    '&quot;': '"',
    '&#39;': "'",
    '&lt;': '<',
    '&gt;': '>',
  };

  final http.Client _client;
  final String token;
  final Duration retryDelay;

  bool get configured => token.isNotEmpty;

  Future<List<ProductHit>> search(String name) async {
    if (!configured) return const [];
    final uri = Uri.https('boardgamegeek.com', '/xmlapi2/search', {
      'query': name,
      'type': 'boardgame',
    });
    try {
      final response = await _client
          .get(uri, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) throw const ProductLookupException();
      return _name
          .allMatches(response.body)
          .map((m) => ProductHit(title: _decode(m.group(1)!)))
          .take(8)
          .toList();
    } on ProductLookupException {
      rethrow;
    } on Object {
      throw const ProductLookupException();
    }
  }

  Future<List<BggCollectionItem>> collection(String username) async {
    if (!configured) return const [];
    final uri = Uri.https('boardgamegeek.com', '/xmlapi2/collection', {
      'username': username,
      'own': '1',
      'subtype': 'boardgame',
      'stats': '1',
    });
    try {
      for (var attempt = 0; attempt < 5; attempt++) {
        final response = await _client
            .get(uri, headers: {'Authorization': 'Bearer $token'})
            .timeout(const Duration(seconds: 15));
        if (response.statusCode == 200) {
          return parseBggCollection(response.body);
        }
        if (response.statusCode != 202) break;
        await Future<void>.delayed(retryDelay);
      }
    } on Object {
      throw const ProductLookupException();
    }
    throw const ProductLookupException();
  }

  String _decode(String text) => _entities.entries.fold(
    text,
    (value, entity) => value.replaceAll(entity.key, entity.value),
  );
}
