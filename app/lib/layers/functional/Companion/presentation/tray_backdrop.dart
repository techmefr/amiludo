import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Dice3D/table_theme.dart';
import 'package:amiludo/layers/technical/Physics/surface_material.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_texture.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

Color _flat(ColorScheme scheme, SurfaceMaterial material) => switch (material) {
  SurfaceMaterial.wood => scheme.tertiaryContainer,
  SurfaceMaterial.felt => scheme.primaryContainer,
  SurfaceMaterial.glass => scheme.surfaceContainerHighest,
};

Color trayRail(ColorScheme scheme) =>
    Color.lerp(toolThemeFor('dice-tray').accent, scheme.scrim, .55)!;

Widget trayFelt(SurfaceMaterial material, bool solid) =>
    !solid && material == SurfaceMaterial.felt
    ? const ToolTextureLayer(texture: ToolTexture.felt, opacity: .12)
    : const SizedBox.shrink();

BoxDecoration trayDecoration(
  ColorScheme scheme,
  SurfaceMaterial material,
  TableTheme? table,
) {
  final radius = BorderRadius.circular(Radii.lg);
  if (table == null) {
    return BoxDecoration(
      color: material == SurfaceMaterial.felt
          ? Color.lerp(
              _flat(scheme, material),
              toolThemeFor('dice-tray').accent,
              .35,
            )
          : _flat(scheme, material),
      borderRadius: radius,
      border: Border.all(color: trayRail(scheme), width: Space.sm),
    );
  }
  return BoxDecoration(
    borderRadius: radius,
    border: Border.all(color: trayRail(scheme), width: Space.sm),
  );
}
