import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tray_sprite.dart';
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
    this.tilt = Tilt.flat,
    this.feedback,
    this.solid = false,
  });
  final DiceTraySession session;
  final int throwId, seed;
  final ValueChanged<int> onTapDie;
  final ValueChanged<List<int>>? onOutcome;
  final double power;
  final Tilt tilt;
  final TrayFeedback? feedback;
  final bool solid;

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
      ..launch(rng(), kept, power: widget.power, sides: sides)
      ..settle(kept);
    final outcome = rehearsal.outcome();
    p.launch(rng(), kept, power: widget.power, sides: sides);
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
    return physics = TrayPhysics(
      width: box.maxWidth,
      height: box.maxHeight,
      radius: _dieSize / 2,
      count: count,
      surface: material,
    )
      ..onImpact = widget.feedback?.impact
      ..settle(const {});
  }

  Color trayColor(ColorScheme scheme) => switch (material) {
    SurfaceMaterial.wood => scheme.tertiaryContainer,
    SurfaceMaterial.felt => scheme.primaryContainer,
    SurfaceMaterial.glass => scheme.surfaceContainerHighest,
  };

  List<Widget> dieAt(TrayPhysics p, int i, ColorScheme scheme) {
    final b = p.bodies[i];
    return traySprite(
      body: b,
      spec: widget.session.settings.dice[i],
      value: b.rolling ? b.face : widget.session.values[i],
      scheme: scheme,
      onTap: () => widget.onTapDie(i),
      solid: widget.solid,
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
          decoration: BoxDecoration(
            color: trayColor(scheme),
            borderRadius: BorderRadius.circular(Radii.lg),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Radii.lg),
            child: Stack(
              children: [
                if (session.thrown)
                  for (var i = 0; i < p.bodies.length; i++)
                    if (!session.kept.contains(i)) ...dieAt(p, i, scheme),
              ],
            ),
          ),
        );
      },
    );
  }
}
