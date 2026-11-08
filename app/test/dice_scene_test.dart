import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';
import 'package:amiludo/layers/technical/Dice3D/table_theme.dart';
import 'package:amiludo/layers/technical/Dice3D/vec3.dart';
import 'package:amiludo/layers/technical/DicePhysics/dice_simulation.dart';
import 'package:amiludo/layers/technical/DiceScene/die_scene.dart';
import 'package:amiludo/layers/technical/DiceScene/scene_camera.dart';
import 'package:amiludo/layers/technical/DiceScene/shadow_scene.dart';
import 'package:amiludo/layers/technical/DiceScene/tray_scene_painter.dart';

const _sides = [2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24, 30, 60, 100, 1000];

void _paint(TrayScenePainter painter, Size size) {
  final recorder = PictureRecorder();
  painter.paint(Canvas(recorder), size);
  recorder.endRecording().dispose();
}

TrayScenePainter _scene(DiceSimulation run, DieSkin skin, TableTheme table) =>
    TrayScenePainter(
      table: table,
      halfWidth: run.world.halfWidth,
      halfDepth: run.world.halfDepth,
      dice: [
        for (final b in run.bodies)
          SceneDie(
            body: b,
            base: skin.base,
            skin: skin,
            label: (v) => '$v',
            pips: true,
          ),
      ],
    );

void main() {
  test('the camera fits the whole table inside any viewport', () {
    for (final size in [
      const Size(390, 360),
      const Size(1280, 480),
      const Size(300, 520),
    ]) {
      final cam = SceneCamera.fit(size, halfWidth: 6, halfDepth: 4.2);
      for (final sx in const [-1.0, 1.0]) {
        for (final sz in const [-1.0, 1.0]) {
          final p = cam.project(
            Vec3(sx * (6 + rimWidth), 0, sz * (4.2 + rimWidth)),
          );
          expect(p.dx, inInclusiveRange(0, size.width), reason: '$size');
          expect(p.dy, inInclusiveRange(0, size.height), reason: '$size');
        }
      }
    }
  });

  test('farther points are drawn smaller than nearer ones', () {
    final cam = SceneCamera.fit(
      const Size(800, 600),
      halfWidth: 6,
      halfDepth: 4.2,
    );
    expect(
      cam.scaleAt(const Vec3(0, 0, 4)),
      greaterThan(cam.scaleAt(const Vec3(0, 0, -4))),
    );
  });

  test('the convex hull keeps only the outline of a point cloud', () {
    final hull = convexHull(const [
      Offset(0, 0),
      Offset(4, 0),
      Offset(4, 4),
      Offset(0, 4),
      Offset(2, 2),
      Offset(1, 3),
    ]);
    expect(hull.length, 4);
  });

  test('every die paints on every skin and table without errors', () {
    final run = DiceSimulation(sides: _sides, seed: 9)..settle();
    for (final skin in DieSkin.all) {
      for (final table in TableTheme.all) {
        _paint(_scene(run, skin, table), const Size(390, 360));
      }
    }
  });

  test('dice paint while they are still tumbling in the air', () {
    final run = DiceSimulation(sides: const [6, 20, 4, 100], seed: 3);
    for (var i = 0; i < 40; i++) {
      run.advance(1 / 30);
      _paint(
        _scene(run, DieSkin.byId('matte'), TableTheme.felt),
        const Size(800, 400),
      );
    }
  });
}
