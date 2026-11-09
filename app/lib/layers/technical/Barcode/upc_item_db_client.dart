import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:amiludo/layers/technical/Barcode/product_lookup.dart';

class UpcItemDbClient {
  UpcItemDbClient({
    http.Client? client,
    this.baseUrl = const String.fromEnvironment(
      'UPCITEMDB_URL',
      defaultValue: 'https://api.upcitemdb.com/prod/trial',
    ),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Future<ProductHit?> lookup(String code) async {
    final uri = Uri.parse('$baseUrl/lookup')
        .replace(queryParameters: {'upc': code});
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 404) return null;
      if (response.statusCode != 200) throw const ProductLookupException();
      return _parse(jsonDecode(response.body));
    } on ProductLookupException {
      rethrow;
    } on Object {
      throw const ProductLookupException();
    }
  }

  ProductHit? _parse(Object? body) {
    final items = body is Map ? body['items'] : null;
    if (items is! List || items.isEmpty || items.first is! Map) return null;
    final item = items.first as Map;
    final title = (item['title'] as String? ?? '').trim();
    if (title.isEmpty) return null;
    final images = item['images'] is List ? item['images'] as List : const [];
    final image = images
        .whereType<String>()
        .where((url) => url.startsWith('https://'))
        .firstOrNull;
    return ProductHit(title: title, imageUrl: image ?? '');
  }
}
