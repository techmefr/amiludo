import 'dart:convert';

import 'package:amiludo/layers/functional/Templates/domain/entities/appearance_item.dart';

class AvatarCatalogue {
  const AvatarCatalogue(this.items, this.palettes);

  factory AvatarCatalogue.decode(String itemsJson, String palettesJson) {
    final items = jsonDecode(itemsJson) as Map<String, dynamic>;
    final palettes = jsonDecode(palettesJson) as Map<String, dynamic>;
    return AvatarCatalogue(
      [
        for (final i in items['items'] as List)
          AppearanceItem.fromJson(Map<String, dynamic>.from(i as Map)),
      ],
      {
        for (final e in (palettes['palettes'] as Map).entries)
          e.key as String: [
            for (final c in e.value as List) parseHex(c as String),
          ],
      },
    );
  }

  static const shape = 'average';

  final List<AppearanceItem> items;
  final Map<String, List<int>> palettes;

  static int parseHex(String hex) =>
      0xFF000000 | int.parse(hex.substring(1), radix: 16);

  List<String> get slots => {for (final i in items) i.slot}.toList();

  List<AppearanceItem> itemsFor(String slot) => [
    for (final i in items)
      if (i.slot == slot && i.variants.containsKey(shape)) i,
  ];

  AppearanceItem? byId(String id) {
    for (final i in items) {
      if (i.id == id) return i;
    }
    return null;
  }

  List<AppearanceLayer> layersOf(AppearanceItem item) =>
      item.variants[shape]?.layers ?? const [];

  String? tintOf(AppearanceItem item) {
    for (final l in layersOf(item)) {
      if (l.tint != null) return l.tint;
    }
    return null;
  }
}
