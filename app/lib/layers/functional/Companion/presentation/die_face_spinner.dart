import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_3d_view.dart';
import 'package:amiludo/layers/technical/Dice3D/die_mesh.dart';
import 'package:amiludo/layers/technical/Dice3D/die_orient.dart';
import 'package:amiludo/layers/technical/Dice3D/die_pose.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';
import 'package:amiludo/layers/technical/Dice3D/vec3.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class DieFaceSpinner extends StatefulWidget {
  const DieFaceSpinner({
    super.key,
    required this.design,
    required this.current,
    required this.onFace,
    this.onTap,
    this.size = 220,
  });
  final DieDesign design;
  final int current;
  final ValueChanged<int> onFace;
  final VoidCallback? onTap;
  final double size;

  @override
  State<DieFaceSpinner> createState() => _DieFaceSpinnerState();
}

class _DieFaceSpinnerState extends State<DieFaceSpinner>
    with SingleTickerProviderStateMixin {
  late DieMesh mesh = DieMesh.forSides(widget.design.sides);
  late int front = mesh.faceOf(widget.current + 1);
  late Mat3 orientation = DiePose.facing(mesh, front);
  late final AnimationController settle = AnimationController(
    vsync: this,
    duration: Motion.slow,
  )..addListener(_settling);
  Mat3 from = Mat3.identity, target = Mat3.identity;

  int designFace(int meshFace) =>
      meshFace.clamp(0, widget.design.faces.length - 1);

  int meshFaceOf(Mat3 pose) {
    var best = 0;
    var facing = -double.infinity;
    for (var i = 0; i < mesh.faces.length; i++) {
      final toward = -pose.apply(mesh.faces[i].normal).z;
      if (toward > facing) {
        facing = toward;
        best = i;
      }
    }
    return best;
  }

  void _settling() => setState(
    () => orientation = settleToward(
      from,
      target,
      Curves.easeOut.transform(settle.value),
    ),
  );

  void _snap(int face) {
    from = orientation;
    target = DiePose.facing(mesh, face);
    if (MediaQuery.disableAnimationsOf(context)) {
      setState(() => orientation = target);
      return;
    }
    settle.forward(from: 0);
  }

  @override
  void didUpdateWidget(DieFaceSpinner old) {
    super.didUpdateWidget(old);
    if (old.design.sides != widget.design.sides) {
      mesh = DieMesh.forSides(widget.design.sides);
      front = mesh.faceOf(widget.current + 1);
      orientation = DiePose.facing(mesh, front);
      return;
    }
    final wanted = mesh.faceOf(widget.current + 1);
    if (designFace(front) != widget.current && wanted != front) {
      front = wanted;
      _snap(front);
    }
  }

  @override
  void dispose() {
    settle.dispose();
    super.dispose();
  }

  void _drag(DragUpdateDetails d) {
    settle.stop();
    final k = pi / widget.size;
    final next =
        Mat3.rotationX(-d.delta.dy * k) *
        Mat3.rotationY(d.delta.dx * k) *
        orientation;
    final face = meshFaceOf(next);
    setState(() {
      orientation = next;
      front = face;
    });
    if (designFace(face) != widget.current) widget.onFace(designFace(face));
  }

  void _drop(DragEndDetails _) => _snap(front);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${widget.design.name} ${widget.design.sides}',
      child: GestureDetector(
        onTap: widget.onTap,
        onPanUpdate: _drag,
        onPanEnd: _drop,
        child: Die3dView(
          spec: DiceSpec.fromDesign(widget.design),
          value: designFace(front) + 1,
          skin: DieSkin.classic,
          size: widget.size,
          orientation: orientation,
          settle: 0,
        ),
      ),
    );
  }
}
