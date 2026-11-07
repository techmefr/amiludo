import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Dice3D/table_theme.dart';
import 'package:amiludo/layers/technical/Physics/surface_material.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

Color _flat(ColorScheme scheme, SurfaceMaterial material) =>
    switch (material) {
      SurfaceMaterial.wood => scheme.tertiaryContainer,
      SurfaceMaterial.felt => scheme.primaryContainer,
      SurfaceMaterial.glass => scheme.surfaceContainerHighest,
    };

BoxDecoration trayDecoration(
  ColorScheme scheme,
  SurfaceMaterial material,
  TableTheme? table,
) {
  final radius = BorderRadius.circular(Radii.lg);
  if (table == null) {
    return BoxDecoration(
      color: _flat(scheme, material),
      borderRadius: radius,
      border: Border.all(color: scheme.outlineVariant),
    );
  }
  return BoxDecoration(borderRadius: radius);
}
