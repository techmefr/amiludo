import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_surface.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_3d_drag.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';
import 'package:amiludo/layers/technical/Physics/tray_body.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const double traySpriteSize = 56;

List<Widget> traySprite({
  required TrayBody body,
  required DiceSpec spec,
  required int value,
  required ColorScheme scheme,
  required VoidCallback onTap,
  bool solid = false,
  DieSkin skin = DieSkin.classic,
}) {
  const size = traySpriteSize;
  final round = TrayBody.roundnessFor(spec.sides);
  final lift = (body.z / size).clamp(0.0, 2.0);
  final tumble = Matrix4.identity()
    ..setEntry(3, 2, 0.003)
    ..rotateX(solid ? 0 : body.flipX * 1.2)
    ..rotateY(solid ? 0 : body.flipY * 1.2)
    ..scaleByDouble(
      (1 + lift * 0.35) * (1 - round * 0.25),
      (1 + lift * 0.35) * (1 - round * 0.25),
      1,
      1,
    );
  return [
    Positioned(
      left: body.x - size / 2 + body.z * 0.25,
      top: body.y - size / 2 + body.z * 0.4,
      child: Opacity(
        opacity: 0.25 / (1 + lift),
        child: Container(
          width: size,
          height: solid ? size * 0.55 : size,
          margin: solid ? EdgeInsets.only(top: size * 0.45) : null,
          decoration: solid
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(size),
                  boxShadow: [
                    BoxShadow(color: scheme.shadow, blurRadius: Space.md),
                  ],
                )
              : BoxDecoration(
                  color: scheme.shadow,
                  borderRadius: BorderRadius.circular(
                    Radii.md + round * size / 2,
                  ),
                ),
        ),
      ),
    ),
    Positioned(
      left: body.x - size / 2,
      top: body.y - size / 2,
      child: GestureDetector(
        onTap: onTap,
        child: Transform(
          alignment: Alignment.center,
          transform: tumble,
          child: Transform.rotate(
            angle: body.angle,
            child: solid
                ? Die3dDrag(
                    spec: spec,
                    value: value,
                    skin: skin,
                    flipX: body.spinX,
                    flipY: body.spinY,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(round * size / 2),
                    child: DieFace(spec: spec, value: value),
                  ),
          ),
        ),
      ),
    ),
  ];
}
