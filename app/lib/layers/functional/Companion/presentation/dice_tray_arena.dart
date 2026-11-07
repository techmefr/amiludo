import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tray_gestures.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tray_sprite.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tray_table.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';
import 'package:amiludo/layers/technical/Dice3D/table_theme.dart';
import 'package:amiludo/layers/technical/Feedback/tray_feedback.dart';
import 'package:amiludo/layers/technical/Physics/fixed_stepper.dart';
import 'package:amiludo/layers/technical/Physics/surface_material.dart';
import 'package:amiludo/layers/technical/Physics/tray_physics.dart';
import 'package:amiludo/layers/technical/Physics/tray_throw.dart';
import 'package:amiludo/layers/technical/Sensors/tray_motion.dart';

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
  final stepper = FixedStepper();
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
    final tilt = widget.tilt;
    if (tilt.x == old.tilt.x && tilt.y == old.tilt.y) return;
    if (MediaQuery.disableAnimationsOf(context)) return;
    if (physics?.setTilt(tilt.x, tilt.y, widget.session.kept) ?? false) run();
  }

  void run() {
    if (ticker.isActive) return;
    stepper.reset();
    ticker.start();
  }

  void onTick(Duration elapsed) {
    final p = physics;
    if (p == null) return;
    final kept = widget.session.kept;
    stepper.advance(p, elapsed, kept);
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
    final outcome = throwTray(
      p,
      seed: widget.seed ^ (widget.throwId * 7919),
      kept: kept,
      sides: [for (final d in widget.session.settings.dice) d.sides],
      power: widget.power,
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
      settleQuietly(p, kept, widget.feedback?.impact);
      throwing = false;
      widget.feedback?.settled();
      return;
    }
    run();
  }

  void swipe(int i, Offset v) {
    if (isLockSwipe(v)) return widget.onTapDie(i);
    if (v.dy < 0) flickAt(v);
  }

  void flickAt(Offset v) {
    final f = flickOf(v);
    if (f != null) widget.onFlick?.call(f.power, f.aim);
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
            radius: traySpriteSize / 2,
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
        return TrayTable(
          material: material,
          solid: widget.solid,
          table: widget.table,
          onTap: widget.onTapTable,
          onPanEnd: (d) => flickAt(d.velocity.pixelsPerSecond),
          children: [
            if (session.thrown)
              for (var i = 0; i < p.bodies.length; i++)
                if (!session.kept.contains(i)) ...dieAt(p, i, scheme),
          ],
        );
      },
    );
  }
}
