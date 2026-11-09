import 'package:flutter/rendering.dart';

import 'package:amiludo/layers/technical/Dice3D/table_theme.dart';
import 'package:amiludo/layers/technical/DiceScene/die_scene.dart';
import 'package:amiludo/layers/technical/DiceScene/scene_camera.dart';
import 'package:amiludo/layers/technical/DiceScene/shadow_scene.dart';
import 'package:amiludo/layers/technical/DiceScene/table_scene.dart';

class TrayScenePainter extends CustomPainter {
  TrayScenePainter({
    required this.dice,
    required this.table,
    required this.halfWidth,
    required this.halfDepth,
    super.repaint,
  });

  final List<SceneDie> dice;
  final TableTheme table;
  final double halfWidth, halfDepth;

  static SceneCamera cameraFor(Size size, double halfWidth, double halfDepth) =>
      SceneCamera.fit(size, halfWidth: halfWidth, halfDepth: halfDepth);

  @override
  void paint(Canvas canvas, Size size) {
    final cam = cameraFor(size, halfWidth, halfDepth);
    final scene = TableScene(cam, table, halfWidth, halfDepth);
    scene.paintBack(canvas, size);
    paintShadows(canvas, cam, [for (final d in dice) d.body]);
    final far = [...dice]
      ..sort((a, b) => cam.depth(b.body.pos).compareTo(cam.depth(a.body.pos)));
    for (final die in far) {
      paintDie(canvas, cam, die);
    }
    scene.paintRim(canvas);
  }

  @override
  bool shouldRepaint(TrayScenePainter old) => true;
}
