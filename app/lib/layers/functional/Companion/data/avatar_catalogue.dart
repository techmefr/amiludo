import 'dart:convert';

import 'package:amiludo/layers/functional/Companion/domain/entities/avatar_look.dart';
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

  static const _defaults = [
    'base.body-base-full-1',
    'head.heads-base-grey-1',
    'eyes.eyes-1',
    'eyebrows.eyebrows-1',
  ];

  int? _colorOf(AppearanceItem item, Map<String, int> tints) {
    final name = tintOf(item);
    final index = name == null ? null : tints[name];
    final colors = name == null ? null : palettes[name];
    if (index == null || colors == null || index >= colors.length) return null;
    return colors[index];
  }

  AvatarLook lookFor({
    required Map<String, int> tints,
    required List<String> pieces,
    required bool hairless,
    AvatarLook base = const AvatarLook(),
  }) {
    var look = base;
    void put(String id, {bool force = true}) {
      final item = byId(id);
      if (item == null) return;
      if (!force && look.picks.containsKey(item.slot)) return;
      look = look.withPick(
        item.slot,
        AvatarPick(item.id, _colorOf(item, tints)),
      );
    }

    for (final id in _defaults) {
      put(id, force: false);
    }
    if (hairless) {
      look = look.withPick('hair', null);
    } else {
      put('hair.hairstyles-1', force: false);
    }
    pieces.forEach(put);
    for (final e in look.picks.entries.toList()) {
      final item = byId(e.value.itemId);
      final color = item == null ? null : _colorOf(item, tints);
      if (color != null) {
        look = look.withPick(e.key, AvatarPick(e.value.itemId, color));
      }
    }
    return look;
  }
}
