import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_face_view.dart';
import 'package:amiludo/layers/technical/Dice3D/die_paths.dart';
import 'package:amiludo/layers/technical/Dice3D/die_pips.dart';
import 'package:amiludo/layers/technical/Dice3D/die_projection.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';

bool usesSkinColors(DiceSpec spec) => !spec.custom && spec.design == null;

Widget die3dFace({
  required DiceSpec spec,
  required ProjectedFace face,
  required Color base,
  required DieSkin skin,
}) {
  final value = face.index + 1;
  final content = spec.faceContent(value);
  final shaded = DieProjection.shade(base, face.light);
  if (usesSkinColors(spec) && content.kind == DieFaceKind.text) {
    if (spec.sides == 6) {
      return DiePips(count: value, color: skin.pip);
    }
    return EngravedNumber(
      text: content.value,
      color: skin.pip,
      light: lighten(shaded, 0.6),
    );
  }
  return DieFaceView(face: content, body: shaded, size: face.contentSize);
}
