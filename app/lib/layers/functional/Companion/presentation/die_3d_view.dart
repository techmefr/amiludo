import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_3d_face.dart';
import 'package:amiludo/layers/technical/Dice3D/die_mesh.dart';
import 'package:amiludo/layers/technical/Dice3D/die_painter.dart';
import 'package:amiludo/layers/technical/Dice3D/die_pose.dart';
import 'package:amiludo/layers/technical/Dice3D/die_projection.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';

const double _contentVisibleFrom = 0.25;

class Die3dView extends StatelessWidget {
  const Die3dView({
    super.key,
    required this.spec,
    required this.value,
    this.flipX = 0,
    this.flipY = 0,
    this.size = 56,
    this.skin = DieSkin.classic,
  });
  final DiceSpec spec;
  final int value;
  final double flipX, flipY;
  final double size;
  final DieSkin skin;

  @override
  Widget build(BuildContext context) {
    final mesh = DieMesh.forSides(spec.sides);
    final face = (value - 1).clamp(0, mesh.faces.length - 1);
    final radius = size * 0.5;
    final shown = DieProjection.faces(
      mesh,
      DiePose.tumbling(mesh, face, flipX, flipY),
      radius,
    );
    final base = usesSkinColors(spec) ? skin.base : Color(spec.color);
    return Semantics(
      label: '${spec.name} ${spec.faceLabel(value)}',
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: DiePainter(
                  faces: shown,
                  base: base,
                  skin: skin,
                  radius: radius,
                  ball: mesh.ball,
                  faceted: !mesh.ball && spec.sides != 6,
                ),
              ),
            ),
            for (final f in shown)
              if (f.facing > _contentVisibleFrom) _content(f, base),
          ],
        ),
      ),
    );
  }

  Widget _content(ProjectedFace f, Color base) => Positioned(
    left: size / 2 + f.center.dx - f.contentSize / 2,
    top: size / 2 + f.center.dy - f.contentSize / 2,
    width: f.contentSize,
    height: f.contentSize,
    child: Transform(
      alignment: Alignment.center,
      transform: Matrix4(
        f.axisX.dx, f.axisX.dy, 0, 0,
        f.axisY.dx, f.axisY.dy, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
      ),
      child: SizedBox.square(
        dimension: f.contentSize,
        child: die3dFace(spec: spec, face: f, base: base, skin: skin),
      ),
    ),
  );
}
