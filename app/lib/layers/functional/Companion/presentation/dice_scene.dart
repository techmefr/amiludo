import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_scene_parts.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tray_gestures.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';
import 'package:amiludo/layers/technical/Dice3D/table_theme.dart';
import 'package:amiludo/layers/technical/Dice3D/vec3.dart';
import 'package:amiludo/layers/technical/DicePhysics/contact.dart';
import 'package:amiludo/layers/technical/DicePhysics/dice_simulation.dart';
import 'package:amiludo/layers/technical/DiceScene/scene_camera.dart';
import 'package:amiludo/layers/technical/DiceScene/tray_scene_painter.dart';
import 'package:amiludo/layers/technical/Feedback/tray_feedback.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const double _halfWidth = 6;
const double _impactScale = 35;

class DiceScene extends StatefulWidget {
  const DiceScene({
    super.key,
    required this.session,
    required this.throwId,
    required this.seed,
    required this.skin,
    required this.table,
    this.power = 1,
    this.aim = Offset.zero,
    this.onOutcome,
    this.onFlick,
    this.onTapTable,
    this.onLongPressDie,
    this.feedback,
  });

  final DiceTraySession session;
  final int throwId, seed;
  final DieSkin skin;
  final TableTheme table;
  final double power;
  final Offset aim;
  final ValueChanged<List<int>>? onOutcome;
  final void Function(double power, Offset aim)? onFlick;
  final VoidCallback? onTapTable;
  final ValueChanged<int>? onLongPressDie;
  final TrayFeedback? feedback;

  @override
  State<DiceScene> createState() => _DiceSceneState();
}

class _DiceSceneState extends State<DiceScene>
    with SingleTickerProviderStateMixin {
  late final Ticker ticker = createTicker(onTick);
  final ValueNotifier<int> frame = ValueNotifier(0);
  final ValueNotifier<int> handles = ValueNotifier(0);
  int ticks = 0;
  DiceSimulation? sim;
  String layout = '';
  int launched = 0;
  bool throwing = false;
  Duration last = Duration.zero;
  Size size = Size.zero;

  List<int> get sides => [
    for (final d in widget.session.settings.dice) d.sides,
  ];

  double halfDepthFor(Size box) => arenaDepthFor(box, _halfWidth);

  @override
  void dispose() {
    ticker.dispose();
    frame.dispose();
    handles.dispose();
    super.dispose();
  }

  Vec3 get heading => headingOf(widget.aim);

  void impact(DieImpactKind kind, double speed) =>
      widget.feedback?.impact(trayImpactOf(kind, speed * _impactScale));

  DiceSimulation simulate(int seed, double depth, {bool aimed = true}) =>
      DiceSimulation(
        sides: sides,
        seed: seed,
        power: aimed ? widget.power : 1,
        aim: aimed ? heading : const Vec3(0, 0, -1),
        halfWidth: _halfWidth,
        halfDepth: depth,
      );

  void ensure(Size box) {
    final depth = halfDepthFor(box);
    final key = '${sides.join(',')}|${depth.toStringAsFixed(1)}';
    if (key == layout && sim != null) return;
    layout = key;
    ticker.stop();
    launched = widget.throwId;
    throwing = false;
    sim = simulate(widget.seed, depth, aimed: false)..settle();
  }

  void launch(Size box, bool reduced) {
    launched = widget.throwId;
    final depth = halfDepthFor(box);
    final seed = widget.seed ^ (widget.throwId * 7919);
    final outcome = (simulate(seed, depth)..settle()).values;
    widget.feedback?.thrown(widget.power);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onOutcome?.call(outcome);
    });
    final run = simulate(seed, depth)..world.onImpact = impact;
    sim = run;
    ticker.stop();
    if (reduced) {
      run.world.onImpact = null;
      run.settle();
      throwing = false;
      widget.feedback?.settled();
      return;
    }
    throwing = true;
    last = Duration.zero;
    ticker.start();
  }

  void onTick(Duration elapsed) {
    final run = sim;
    if (run == null) return;
    run.advance((elapsed - last).inMicroseconds / 1e6);
    last = elapsed;
    frame.value++;
    if (++ticks % 8 == 0 || run.settled) handles.value++;
    if (!run.settled) return;
    ticker.stop();
    if (throwing) widget.feedback?.settled();
    throwing = false;
  }

  SceneCamera get camera =>
      TrayScenePainter.cameraFor(size, _halfWidth, halfDepthFor(size));

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.lg),
      child: LayoutBuilder(
        builder: (context, box) {
          size = box.biggest;
          ensure(size);
          if (launched != widget.throwId && widget.session.thrown) {
            launch(size, reduced);
          }
          final run = sim!;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTapTable,
            onPanEnd: (d) =>
                routeSwipe(d.velocity.pixelsPerSecond, widget.onFlick),
            onLongPressStart: (d) {
              final hit = pickDie(camera, run.bodies, d.localPosition);
              if (hit != null) widget.onLongPressDie?.call(hit);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: TrayScenePainter(
                    repaint: frame,
                    table: widget.table,
                    halfWidth: _halfWidth,
                    halfDepth: halfDepthFor(size),
                    dice: [
                      for (var i = 0; i < run.bodies.length; i++)
                        sceneDieFor(
                          widget.session.settings.dice[i],
                          run.bodies[i],
                          widget.skin,
                        ),
                    ],
                  ),
                ),
                if (widget.session.thrown)
                  ValueListenableBuilder<int>(
                    valueListenable: handles,
                    builder: (context, _, _) => Stack(
                      children: dieHandles(
                        camera,
                        run.bodies,
                        widget.session,
                        widget.skin,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
