import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/aura/aura_background.dart';
import 'package:amiludo/layers/technical/Theme/components/aura/aura_presets.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const double auraPreviewHeight = 72;

class AuraPreview extends StatelessWidget {
  const AuraPreview({super.key, required this.skin, required this.theme});
  final String skin;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(Radii.md),
    child: SizedBox(
      height: auraPreviewHeight,
      width: double.infinity,
      child: AuraBackground(
        key: ValueKey('aura-preview-$skin'),
        preset: AuraPresets.skin(skin),
        theme: theme,
        animate: false,
      ),
    ),
  );
}
