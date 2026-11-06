import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_face_view.dart';
import 'package:amiludo/layers/technical/Dice3D/die_mesh.dart';
import 'package:amiludo/layers/technical/Dice3D/die_painter.dart';
import 'package:amiludo/layers/technical/Dice3D/die_pose.dart';
import 'package:amiludo/layers/technical/Dice3D/die_projection.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';

const double _contentVisibleFrom = 0.25;

class Die3dView extends StatelessWidget {
  const Die3dView({
    super.key,
    required this.spec,
    required this.value,
    this.flipX = 0,
    this.flipY = 0,
    this.size = 56,
  });
  final DiceSpec spec;
  final int value;
  final double flipX, flipY;
  final double size;

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
    final base = Color(spec.color);
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
                  edge: readableOn(base).withValues(alpha: 0.35),
                  radius: radius,
                  ball: mesh.ball,
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
      child: DieFaceView(
        face: spec.faceContent(f.index + 1),
        body: DieProjection.shade(base, f.light),
        size: f.contentSize,
      ),
    ),
  );
}
