import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_scene_parts.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_face_view.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';
import 'package:amiludo/layers/technical/Dice3D/table_theme.dart';
import 'package:amiludo/layers/technical/DicePhysics/dice_simulation.dart';
import 'package:amiludo/layers/technical/DiceScene/face_marks.dart';
import 'package:amiludo/layers/technical/DiceScene/scene_camera.dart';
import 'package:amiludo/layers/technical/DiceScene/scene_light.dart';
import 'package:amiludo/layers/technical/DiceScene/tray_scene_painter.dart';

const double _artBox = 100;

class DiceSceneLayers extends StatelessWidget {
  const DiceSceneLayers({
    super.key,
    required this.run,
    required this.session,
    required this.skin,
    required this.table,
    required this.camera,
    required this.halfWidth,
    required this.halfDepth,
    required this.frame,
    required this.handles,
  });

  final DiceSimulation run;
  final DiceTraySession session;
  final DieSkin skin;
  final TableTheme table;
  final SceneCamera camera;
  final double halfWidth, halfDepth;
  final Listenable frame, handles;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: TrayScenePainter(
            repaint: frame,
            table: table,
            halfWidth: halfWidth,
            halfDepth: halfDepth,
            dice: [
              for (var i = 0; i < run.bodies.length; i++)
                sceneDieFor(session.settings.dice[i], run.bodies[i], skin),
            ],
          ),
        ),
        if (session.thrown)
          ListenableBuilder(
            listenable: handles,
            builder: (context, _) => Stack(
              children: [
                ...dieHandles(camera, run.bodies, session, skin),
                if (run.settled) ..._faceArt(),
              ],
            ),
          ),
      ],
    );
  }

  List<Widget> _faceArt() {
    final order = [for (var i = 0; i < run.bodies.length; i++) i]
      ..sort(
        (a, b) => camera
            .depth(run.bodies[b].pos)
            .compareTo(camera.depth(run.bodies[a].pos)),
      );
    final art = <Widget>[];
    for (final i in order) {
      final spec = session.settings.dice[i];
      if (spec.design == null) continue;
      final body = run.bodies[i];
      final base = Color(spec.color);
      for (final face in body.shape.valued) {
        final content = spec.faceContent(face.value);
        final facing = facingOf(camera, body, face);
        if (content.kind == DieFaceKind.text || facing < 0.3) continue;
        art.add(
          Positioned(
            left: 0,
            top: 0,
            width: _artBox,
            height: _artBox,
            child: IgnorePointer(
              child: Transform(
                transform: faceMatrix(camera, body, face).multiplied(
                  Matrix4.translationValues(-_artBox / 2, -_artBox / 2, 0),
                ),
                child: Opacity(
                  opacity: ((facing - 0.3) / 0.3).clamp(0.0, 1.0),
                  child: DieFaceView(
                    face: content,
                    body: lit(base, body.normalOf(face)),
                    size: _artBox,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return art;
  }
}
