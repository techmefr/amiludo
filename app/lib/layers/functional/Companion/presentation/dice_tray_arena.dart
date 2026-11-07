import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tray_backdrop.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tray_sprite.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';
import 'package:amiludo/layers/technical/Dice3D/table_painter.dart';
import 'package:amiludo/layers/technical/Dice3D/table_theme.dart';
import 'package:amiludo/layers/technical/Feedback/tray_feedback.dart';
import 'package:amiludo/layers/technical/Physics/seeded_random.dart';
import 'package:amiludo/layers/technical/Physics/surface_material.dart';
import 'package:amiludo/layers/technical/Physics/tray_physics.dart';
import 'package:amiludo/layers/technical/Sensors/tray_motion.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const double _dieSize = traySpriteSize;

class DiceTraySurface extends StatefulWidget {
  const DiceTraySurface({
    super.key,
    required this.session,
    required this.throwId,
    required this.seed,
    required this.onTapDie,
    this.onOutcome,
    this.power = 1,
    this.aim = Offset.zero,
    this.onFlick,
    this.onTapTable,
    this.tilt = Tilt.flat,
    this.feedback,
    this.solid = false,
    this.skin = DieSkin.classic,
    this.table = TableTheme.felt,
  });
  final DiceTraySession session;
  final int throwId, seed;
  final ValueChanged<int> onTapDie;
  final ValueChanged<List<int>>? onOutcome;
  final double power;
  final Offset aim;
  final void Function(double power, Offset aim)? onFlick;
  final VoidCallback? onTapTable;
  final Tilt tilt;
  final TrayFeedback? feedback;
  final bool solid;
  final DieSkin skin;
  final TableTheme table;

  @override
  State<DiceTraySurface> createState() => _DiceTraySurfaceState();
}

class _DiceTraySurfaceState extends State<DiceTraySurface>
    with SingleTickerProviderStateMixin {
  late final Ticker ticker = createTicker(onTick);
  TrayPhysics? physics;
  Duration last = Duration.zero;
  double carry = 0;
  int launched = 0;
  bool throwing = false;

  SurfaceMaterial get material =>
      SurfaceMaterial.parse(widget.session.settings.surface);

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DiceTraySurface old) {
    super.didUpdateWidget(old);
    final p = physics;
    if (p == null || MediaQuery.disableAnimationsOf(context)) return;
    final tilt = widget.tilt;
    if (tilt.x == old.tilt.x && tilt.y == old.tilt.y) return;
    if (p.setTilt(tilt.x, tilt.y, widget.session.kept)) run();
  }

  void run() {
    if (ticker.isActive) return;
    last = Duration.zero;
    carry = 0;
    ticker.start();
  }

  void onTick(Duration elapsed) {
    final p = physics;
    if (p == null) return;
    carry += (elapsed - last).inMicroseconds / 1e6;
    last = elapsed;
    final kept = widget.session.kept;
    var steps = 0;
    while (carry >= TrayPhysics.step && steps++ < 6) {
      p.advance(TrayPhysics.step, kept);
      carry -= TrayPhysics.step;
    }
    if (!p.isMoving(kept)) {
      ticker.stop();
      if (throwing) widget.feedback?.settled();
      throwing = false;
    }
    setState(() {});
  }

  void launch(TrayPhysics p, bool reduced) {
    launched = widget.throwId;
    final kept = widget.session.kept;
    final sides = [for (final d in widget.session.settings.dice) d.sides];
    SeededRandom rng() => SeededRandom(widget.seed ^ (widget.throwId * 7919));
    final rehearsal = p.copy()
      ..launch(
        rng(),
        kept,
        power: widget.power,
        sides: sides,
        aimX: widget.aim.dx,
        aimY: widget.aim.dy,
      )
      ..settle(kept);
    final outcome = rehearsal.outcome();
    p.launch(
      rng(),
      kept,
      power: widget.power,
      sides: sides,
      aimX: widget.aim.dx,
      aimY: widget.aim.dy,
    );
    widget.feedback?.thrown(widget.power);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onOutcome?.call(outcome);
    });
    ticker.stop();
    throwing = true;
    if (reduced) {
      p.onImpact = null;
      p.settle(kept);
      p.onImpact = widget.feedback?.impact;
      throwing = false;
      widget.feedback?.settled();
      return;
    }
    run();
  }

  void swipe(int i, Offset v) {
    if (v.distance < 400) return;
    if (v.dx < 0 && v.dx.abs() > v.dy.abs()) {
      widget.onTapDie(i);
    } else if (v.dy < 0) {
      flick(DragEndDetails(velocity: Velocity(pixelsPerSecond: v)));
    }
  }

  void flick(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond;
    if (v.distance < 400) return;
    widget.onFlick?.call((v.distance / 1800).clamp(0.5, 1.5), v / v.distance);
  }

  TrayPhysics bodyFor(BoxConstraints box) {
    final count = widget.session.settings.dice.length;
    final current = physics;
    if (current != null &&
        current.width == box.maxWidth &&
        current.height == box.maxHeight &&
        current.surface == material &&
        current.bodies.length == count) {
      return current;
    }
    ticker.stop();
    launched = widget.throwId;
    return physics =
        TrayPhysics(
            width: box.maxWidth,
            height: box.maxHeight,
            radius: _dieSize / 2,
            count: count,
            surface: material,
          )
          ..onImpact = widget.feedback?.impact
          ..settle(const {});
  }

  List<Widget> dieAt(TrayPhysics p, int i, ColorScheme scheme) {
    final b = p.bodies[i];
    return traySprite(
      body: b,
      spec: widget.session.settings.dice[i],
      value: b.rolling ? b.face : widget.session.values[i],
      scheme: scheme,
      onTap: () => widget.onTapDie(i),
      onSwipe: (v) => swipe(i, v),
      solid: widget.solid,
      skin: widget.skin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final session = widget.session;
    widget.feedback?.material = material;
    return LayoutBuilder(
      builder: (context, box) {
        final p = bodyFor(box);
        if (launched != widget.throwId && session.thrown) launch(p, reduced);
        return Container(
          decoration: trayDecoration(
            scheme,
            material,
            widget.solid ? widget.table : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Radii.lg),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTapTable,
              onPanEnd: flick,
              child: Stack(
                children: [
                  trayFelt(material, widget.solid),
                  if (widget.solid)
                    Positioned.fill(
                      child: CustomPaint(painter: TablePainter(widget.table)),
                    ),
                  if (session.thrown)
                    for (var i = 0; i < p.bodies.length; i++)
                      if (!session.kept.contains(i)) ...dieAt(p, i, scheme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
