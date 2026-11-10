import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_face_view.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const double _dieSize = 56;

class DieFace extends StatelessWidget {
  const DieFace({
    super.key,
    required this.spec,
    required this.value,
    this.kept = false,
    this.size = _dieSize,
  });
  final DiceSpec spec;
  final int value;
  final bool kept;
  final double size;

  @override
  Widget build(BuildContext context) {
    final background = Color(spec.color);
    final ink = readableOn(background);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: '${spec.name} ${spec.faceLabel(value)}',
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(
            color: kept ? scheme.accentInk : ink.withValues(alpha: 0.4),
            width: kept ? 3 : 1,
          ),
        ),
        child: DieFaceView(
          face: spec.faceContent(value),
          body: background,
          size: size,
        ),
      ),
    );
  }
}
