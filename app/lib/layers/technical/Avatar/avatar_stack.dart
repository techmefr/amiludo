import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Avatar/avatar_fit.dart';

class AvatarLayerSpec {
  const AvatarLayerSpec({
    required this.order,
    required this.asset,
    this.tint,
    this.box,
    this.target,
    this.flip = false,
  });
  final int order;
  final String asset;
  final Color? tint;
  final Rect? box;
  final Rect? target;
  final bool flip;

  Rect? get placement =>
      box == null || target == null ? null : fitRect(box!, target!);
}

List<AvatarLayerSpec> orderedLayers(
  Iterable<AvatarLayerSpec> layers,
  Set<String> hiddenAssets,
) {
  final kept = layers.where((l) => !hiddenAssets.contains(l.asset)).toList();
  final indexed = {for (var i = 0; i < kept.length; i++) kept[i]: i};
  kept.sort((a, b) {
    final byOrder = a.order.compareTo(b.order);
    return byOrder != 0 ? byOrder : indexed[a]!.compareTo(indexed[b]!);
  });
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

  Widget _image(AvatarLayerSpec l) {
    final image = Image.asset(
      'assets/${l.asset}.png',
      fit: BoxFit.contain,
      color: l.tint,
      colorBlendMode: BlendMode.modulate,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
    return l.flip ? Transform.flip(flipX: true, child: image) : image;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, box) {
            final side = box.biggest.shortestSide;
            return Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                for (final l in orderedLayers(layers, hiddenAssets))
                  if (l.placement case final p?)
                    Positioned(
                      left: p.left * side,
                      top: p.top * side,
                      width: p.width * side,
                      height: p.height * side,
                      child: _image(l),
                    )
                  else
                    Positioned.fill(child: _image(l)),
              ],
            );
          },
        ),
      ),
    );
  }
}
