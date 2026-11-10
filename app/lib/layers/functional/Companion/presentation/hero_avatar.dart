import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/data/avatar_catalogue.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/avatar_look.dart';
import 'package:amiludo/layers/technical/Avatar/avatar_fit.dart';
import 'package:amiludo/layers/technical/Avatar/avatar_stack.dart';

Rect? _boxOf(List<double>? b) =>
    b == null ? null : Rect.fromLTRB(b[0], b[1], b[2], b[3]);

List<AvatarLayerSpec> avatarLayers(AvatarLook look, AvatarCatalogue catalogue) {
  final layers = <AvatarLayerSpec>[];
  final hidden = catalogue.hiddenSlots(look);
  for (final entry in look.picks.entries) {
    if (hidden.contains(entry.key)) continue;
    final pick = entry.value;
    final item = catalogue.byId(pick.itemId);
    if (item == null) continue;
    final place = catalogue.rig?.placementOf(item.id);
    if (place?.hidden ?? false) continue;
    for (final layer in catalogue.layersOf(item)) {
      final tint = layer.tint;
      final fallback = tint == null ? null : catalogue.palettes[tint]?.first;
      final value = tint == null ? null : (pick.color ?? fallback);
      final color = value == null ? null : Color(value);
      final box = _boxOf(layer.box);
      final order = place?.z ?? layer.order;
      layers.add(
        AvatarLayerSpec(
          order: order,
          asset: layer.src,
          tint: color,
          box: box,
          target: place?.rect,
        ),
      );
      if (place != null && place.pair && box != null && place.rect != null) {
        layers.add(
          AvatarLayerSpec(
            order: order,
            asset: layer.src,
            tint: color,
            box: mirrorRect(box),
            target: mirrorRect(place.rect!),
            flip: true,
          ),
        );
      }
    }
  }
  return layers;
}

class HeroAvatar extends StatelessWidget {
  const HeroAvatar({
    super.key,
    required this.look,
    required this.catalogue,
    this.label,
  });
  final AvatarLook look;
  final AvatarCatalogue catalogue;
  final String? label;

  @override
  Widget build(BuildContext context) =>
      AvatarStack(layers: avatarLayers(look, catalogue), semanticLabel: label);
}
