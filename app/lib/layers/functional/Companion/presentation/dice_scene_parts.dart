import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_3d_face.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_3d_view.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';
import 'package:amiludo/layers/technical/Dice3D/vec3.dart';
import 'package:amiludo/layers/technical/DicePhysics/contact.dart';
import 'package:amiludo/layers/technical/DicePhysics/die_body.dart';
import 'package:amiludo/layers/technical/DiceScene/die_scene.dart';
import 'package:amiludo/layers/technical/DiceScene/scene_camera.dart';
import 'package:amiludo/layers/technical/Physics/tray_body.dart';

SceneDie sceneDieFor(DiceSpec spec, DieBody body, DieSkin skin) {
  final skinned = usesSkinColors(spec);
  final base = skinned ? skin.base : Color(spec.color);
  return SceneDie(
    body: body,
    base: base,
    skin: skin,
    ink: skinned
        ? null
        : (base.computeLuminance() > 0.5
              ? const Color(0xFF1E1A22)
              : const Color(0xFFF6F3EE)),
    label: (v) {
      final content = spec.faceContent(v);
      return content.kind == DieFaceKind.text ? content.value : null;
    },
    pips: skinned && spec.sides == 6,
  );
}

List<Widget> dieHandles(
  SceneCamera cam,
  List<DieBody> bodies,
  DiceTraySession session,
  DieSkin skin,
) {
  final values = session.values;
  return [
    for (var i = 0; i < bodies.length && i < values.length; i++)
      _handle(cam, bodies[i], session.settings.dice[i], values[i], skin),
  ];
}

Widget _handle(
  SceneCamera cam,
  DieBody body,
  DiceSpec spec,
  int value,
  DieSkin skin,
) {
  final at = cam.project(body.pos);
  final r = cam.scaleAt(body.pos) * body.size;
  return Positioned(
    left: at.dx - r,
    top: at.dy - r,
    width: r * 2,
    height: r * 2,
    child: Opacity(
      opacity: 0.004,
      child: Die3dView(spec: spec, value: value, size: r * 2, skin: skin),
    ),
  );
}

int? pickDie(SceneCamera cam, List<DieBody> bodies, Offset at) {
  int? best;
  var reach = double.infinity;
  for (var i = 0; i < bodies.length; i++) {
    final b = bodies[i];
    final d = (cam.project(b.pos) - at).distance;
    if (d < cam.scaleAt(b.pos) * b.size * 1.2 && d < reach) {
      reach = d;
      best = i;
    }
  }
  return best;
}

TrayImpact trayImpactOf(DieImpactKind kind, double speed) =>
    TrayImpact(switch (kind) {
      DieImpactKind.table => ImpactKind.floor,
      DieImpactKind.wall => ImpactKind.wall,
      DieImpactKind.die => ImpactKind.die,
    }, speed);

Vec3 headingOf(Offset aim) => aim == Offset.zero
    ? const Vec3(0, 0, -1)
    : Vec3(aim.dx * 0.8, 0, aim.dy.clamp(-1.0, -0.35)).unit;

double arenaDepthFor(Size box, double halfWidth) =>
    (halfWidth * box.height / box.width * 1.3).clamp(3.4, 8.0);

double arenaWidthFor(Size box, int count) {
  final small = count <= 3;
  final floor = small ? 5.2 : (count <= 6 ? 4.6 : (count <= 12 ? 5.4 : 6.2));
  final depth = small ? 3.2 : (count <= 6 ? 3.8 : (count <= 12 ? 4.6 : 5.6));
  return (depth * box.width / box.height / 1.3).clamp(
    floor,
    small ? 5.2 : (count <= 6 ? 6.8 : 9.0),
  );
}

double dieSizeFor(int count) => count <= 3 ? 1.6 : (count <= 6 ? 1.3 : 1);
