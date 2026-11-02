import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import 'game_template.dart';

class PackCatalog {
  static const url =
      'https://techmefr.github.io/ludoply/community/catalog.json';
  static List<GameTemplate> decode(String text) {
    if (text.length > 2000000) {
      throw const FormatException('Catalogue trop volumineux');
    }
    final j = jsonDecode(text) as Map<String, dynamic>;
    if (j['format'] != 'table-companion-catalog' ||
        j['version'] != 1 ||
        (j['packs'] as List).length > 500) {
      throw const FormatException('Catalogue incompatible');
    }
    final packs = (j['packs'] as List)
        .map((v) => GameTemplate.fromJson(Map<String, dynamic>.from(v as Map)))
        .toList();
    if (packs.map((p) => p.id).toSet().length != packs.length ||
        packs.any(
          (p) =>
              GameTemplate.builtIn.any((b) => b.id == p.id) ||
              p.author.trim().isEmpty ||
              p.license.trim().isEmpty,
        )) {
      throw const FormatException(
        'Identifiants ou crédits du catalogue invalides',
      );
    }
    return packs;
  }

  static Future<List<GameTemplate>> fetch() async {
    final client = http.Client();
    try {
      return await (() async {
        final response = await client.send(http.Request('GET', Uri.parse(url)));
        if (response.statusCode != 200) {
          throw const FormatException(
            'La galerie ne répond pas. Réessayez plus tard.',
          );
        }
        final bytes = <int>[];
        await for (final chunk in response.stream) {
          bytes.addAll(chunk);
          if (bytes.length > 2000000) {
            throw const FormatException('Catalogue trop volumineux');
          }
        }
        return decode(utf8.decode(bytes));
      })().timeout(const Duration(seconds: 20));
    } finally {
      client.close();
    }
  }
}
