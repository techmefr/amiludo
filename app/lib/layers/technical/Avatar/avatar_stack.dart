import 'package:flutter/material.dart';

class AvatarLayerSpec {
  const AvatarLayerSpec({required this.order, required this.asset, this.tint});
  final int order;
  final String asset;
  final Color? tint;
}

List<AvatarLayerSpec> orderedLayers(
  Iterable<AvatarLayerSpec> layers,
  Set<String> hiddenAssets,
) {
  final kept = layers.where((l) => !hiddenAssets.contains(l.asset)).toList()
    ..sort((a, b) => a.order.compareTo(b.order));
  return kept;
}

class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.layers,
    this.hiddenAssets = const {},
    this.semanticLabel,
  });

  final List<AvatarLayerSpec> layers;
  final Set<String> hiddenAssets;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            for (final l in orderedLayers(layers, hiddenAssets))
              Image.asset(
                'assets/${l.asset}.png',
                fit: BoxFit.contain,
                color: l.tint,
                colorBlendMode: BlendMode.modulate,
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}
