import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/World/presentation/world_viewport.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';

class ZoomButtons extends StatelessWidget {
  const ZoomButtons({required this.controller});
  final WorldViewportController controller;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      children: [
        IconButton.filledTonal(
          tooltip: l.worldZoomIn,
          onPressed: () => controller.zoomBy(1.6),
          icon: const DeckIcon(Icons.add),
        ),
        IconButton.filledTonal(
          tooltip: l.worldZoomOut,
          onPressed: () => controller.zoomBy(1 / 1.6),
          icon: const DeckIcon(Icons.remove),
        ),
        IconButton.filledTonal(
          tooltip: l.worldZoomReset,
          onPressed: controller.reset,
          icon: const Icon(Icons.center_focus_strong_outlined),
        ),
      ],
    );
  }
}
