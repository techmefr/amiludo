import 'dart:convert';

import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';

class PackCatalog {
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
}
