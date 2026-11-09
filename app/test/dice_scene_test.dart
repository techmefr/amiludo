import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_scene_layers.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_face_view.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';
import 'package:amiludo/layers/technical/Dice3D/table_theme.dart';
import 'package:amiludo/layers/technical/Dice3D/vec3.dart';
import 'package:amiludo/layers/technical/DicePhysics/dice_simulation.dart';
import 'package:amiludo/layers/technical/DiceScene/die_scene.dart';
import 'package:amiludo/layers/technical/DiceScene/scene_camera.dart';
import 'package:amiludo/layers/technical/DiceScene/shadow_scene.dart';
import 'package:amiludo/layers/technical/DiceScene/tray_scene_painter.dart';
import 'package:amiludo/layers/technical/Physics/seeded_random.dart';

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
  _tiltTests();
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

  test('the overhead camera projects the floor symmetrically', () {
    final cam = SceneCamera.fit(
      const Size(800, 600),
      halfWidth: 6,
      halfDepth: 4.2,
    );
    final near = cam.project(const Vec3(4, 0, 3));
    final far = cam.project(const Vec3(4, 0, -3));
    expect(near.dx, far.dx);
    expect(near.dy + far.dy, closeTo(600, 0.001));
    expect(cam.depth(const Vec3(0, 0, 4)), cam.depth(const Vec3(0, 0, -4)));
    expect(
      cam.scaleAt(const Vec3(0, 1, 0)),
      greaterThan(cam.scaleAt(Vec3.zero)),
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

void _tiltTests() {
  test('tilting slides settled dice without turning them, then they rest', () {
    final run = DiceSimulation(sides: const [6, 20], seed: 5)..settle();
    final before = run.values;
    final x = run.bodies.first.pos.x;
    run.tilt(const Vec3(24, 0, 0));
    expect(run.settled, isFalse);
    for (var i = 0; i < 60; i++) {
      run.advance(1 / 30);
    }
    expect(run.bodies.first.pos.x, greaterThan(x));
    expect(run.values, before);
    run.tilt(Vec3.zero);
    run.settle();
    expect(run.settled, isTrue);
    expect(run.values, before);
  });

  test('3D with the matte skin is the default look', () {
    const appearance = Appearance();
    expect(appearance.dice3d, isTrue);
    expect(appearance.dieSkin, 'matte');
    expect(DieSkin.byId(appearance.dieSkin).finish, DieFinish.matte);
  });

  testWidgets('icon and image faces are drawn on the settled die', (
    tester,
  ) async {
    final design = DieDesign(
      id: 'art',
      name: 'Art',
      faces: [
        for (var i = 0; i < 6; i++)
          const DieFaceContent(kind: DieFaceKind.icon, value: 'sword'),
      ],
    );
    final run = DiceSimulation(sides: const [6], seed: 2)..settle();
    final session = DiceTraySession(
      settings: DiceTraySettings(dice: [DiceSpec.fromDesign(design)]),
    ).throwDice(SeededRandom(1)).withOutcome(run.values);
    final cam = SceneCamera.fit(
      const Size(400, 300),
      halfWidth: run.world.halfWidth,
      halfDepth: run.world.halfDepth,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 400,
          height: 300,
          child: DiceSceneLayers(
            run: run,
            session: session,
            skin: DieSkin.byId('matte'),
            table: TableTheme.felt,
            camera: cam,
            halfWidth: run.world.halfWidth,
            halfDepth: run.world.halfDepth,
            frame: ValueNotifier(0),
            handles: ValueNotifier(0),
          ),
        ),
      ),
    );
    expect(find.byType(DieFaceView), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
