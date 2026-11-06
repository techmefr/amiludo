import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/avatar_catalogue.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/avatar_look.dart';
import 'package:amiludo/layers/technical/Avatar/avatar_stack.dart';

List<AvatarLayerSpec> avatarLayers(AvatarLook look, AvatarCatalogue catalogue) {
  final layers = <AvatarLayerSpec>[];
  for (final pick in look.picks.values) {
    final item = catalogue.byId(pick.itemId);
    if (item == null) continue;
    for (final layer in catalogue.layersOf(item)) {
      final tint = layer.tint;
      final fallback = tint == null ? null : catalogue.palettes[tint]?.first;
      final value = tint == null ? null : (pick.color ?? fallback);
      layers.add(
        AvatarLayerSpec(
          order: layer.order,
          asset: layer.src,
          tint: value == null ? null : Color(value),
        ),
      );
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
  Widget build(BuildContext context) => AvatarStack(
    layers: avatarLayers(look, catalogue),
    semanticLabel: label,
  );
}
