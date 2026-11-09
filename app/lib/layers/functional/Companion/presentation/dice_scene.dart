import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_scene_layers.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_scene_parts.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tray_gestures.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';
import 'package:amiludo/layers/technical/Dice3D/table_theme.dart';
import 'package:amiludo/layers/technical/Dice3D/vec3.dart';
import 'package:amiludo/layers/technical/DicePhysics/dice_simulation.dart';
import 'package:amiludo/layers/technical/DiceScene/scene_camera.dart';
import 'package:amiludo/layers/technical/DiceScene/tray_scene_painter.dart';
import 'package:amiludo/layers/technical/Feedback/tray_feedback.dart';
import 'package:amiludo/layers/technical/Sensors/tray_motion.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const double _impactScale = 35;
const double _leanScale = 26;
const double _leanDeadZone = 0.12;

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
    this.tilt = Tilt.flat,
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
  final Tilt tilt;
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
  int ticks = 0, launched = 0;
  DiceSimulation? sim;
  String layout = '';
  bool throwing = false;
  Duration last = Duration.zero;
  Size size = Size.zero;

  List<int> get sides => [
    for (final d in widget.session.settings.dice) d.sides,
  ];

  double get halfWidth => arenaWidthFor(size, sides.length);

  double get halfDepth => arenaDepthFor(size, halfWidth);

  SceneCamera get camera =>
      TrayScenePainter.cameraFor(size, halfWidth, halfDepth);

  @override
  void dispose() {
    ticker.dispose();
    frame.dispose();
    handles.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DiceScene old) {
    super.didUpdateWidget(old);
    final t = widget.tilt;
    if (t.x == old.tilt.x && t.y == old.tilt.y) return;
    if (MediaQuery.disableAnimationsOf(context)) return;
    final lean = Vec3(t.x, 0, t.y);
    sim?.tilt(lean.length < _leanDeadZone ? Vec3.zero : lean * _leanScale);
    run();
  }

  void run() {
    final current = sim;
    if (current == null || current.settled || ticker.isActive) return;
    last = Duration.zero;
    ticker.start();
  }

  DiceSimulation simulate(int seed, {bool aimed = true}) => DiceSimulation(
    sides: sides,
    seed: seed,
    power: aimed ? widget.power : 1,
    aim: aimed ? headingOf(widget.aim) : const Vec3(0, 0, -1),
    halfWidth: halfWidth,
    halfDepth: halfDepth,
  );

  void ensure() {
    final key =
        '${sides.join(',')}|${halfWidth.toStringAsFixed(1)}|${halfDepth.toStringAsFixed(1)}';
    if (key == layout && sim != null) return;
    layout = key;
    ticker.stop();
    launched = widget.throwId;
    throwing = false;
    sim = simulate(widget.seed, aimed: false)..settle();
  }

  void launch(bool reduced) {
    launched = widget.throwId;
    final seed = widget.seed ^ (widget.throwId * 7919);
    final outcome = (simulate(seed)..settle()).values;
    widget.feedback?.thrown(widget.power);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onOutcome?.call(outcome);
    });
    final next = simulate(seed)
      ..world.onImpact = (kind, speed) =>
          widget.feedback?.impact(trayImpactOf(kind, speed * _impactScale));
    sim = next;
    ticker.stop();
    if (reduced) {
      next.world.onImpact = null;
      next.settle();
      widget.feedback?.settled();
      return;
    }
    throwing = true;
    run();
  }

  void onTick(Duration elapsed) {
    final current = sim;
    if (current == null) return;
    current.advance((elapsed - last).inMicroseconds / 1e6);
    last = elapsed;
    frame.value++;
    if (++ticks % 8 == 0 || current.settled) handles.value++;
    if (!current.settled) return;
    ticker.stop();
    if (throwing) widget.feedback?.settled();
    throwing = false;
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.lg),
      child: LayoutBuilder(
        builder: (context, box) {
          size = box.biggest;
          ensure();
          if (launched != widget.throwId && widget.session.thrown) {
            launch(reduced);
          }
          final current = sim!;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTapTable,
            onPanEnd: (d) =>
                routeSwipe(d.velocity.pixelsPerSecond, widget.onFlick),
            onLongPressStart: (d) {
              final hit = pickDie(camera, current.bodies, d.localPosition);
              if (hit != null) widget.onLongPressDie?.call(hit);
            },
            child: DiceSceneLayers(
              run: current,
              session: widget.session,
              skin: widget.skin,
              table: widget.table,
              camera: camera,
              halfWidth: halfWidth,
              halfDepth: halfDepth,
              frame: frame,
              handles: handles,
            ),
          );
        },
      ),
    );
  }
}
