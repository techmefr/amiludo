import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/technical/Physics/seeded_random.dart';
import 'package:amiludo/layers/technical/Physics/tray_physics.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const double _dieSize = 56;

class DieFace extends StatelessWidget {
  const DieFace({
    super.key,
    required this.spec,
    required this.value,
    this.kept = false,
    this.size = _dieSize,
  });
  final DiceSpec spec;
  final int value;
  final bool kept;
  final double size;

  @override
  Widget build(BuildContext context) {
    final background = Color(spec.color);
    final ink = readableOn(background);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: '${spec.name} ${spec.faceLabel(value)}',
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(
            color: kept ? scheme.primary : ink.withValues(alpha: 0.4),
            width: kept ? 3 : 1,
          ),
        ),
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(Space.sm),
            child: Text(
              spec.faceLabel(value),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DiceTraySurface extends StatefulWidget {
  const DiceTraySurface({
    super.key,
    required this.session,
    required this.throwId,
    required this.seed,
    required this.onTapDie,
  });
  final DiceTraySession session;
  final int throwId, seed;
  final ValueChanged<int> onTapDie;

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

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
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
    if (!p.isMoving(kept)) ticker.stop();
    setState(() {});
  }

  void launch(TrayPhysics p, bool reduced) {
    launched = widget.throwId;
    final kept = widget.session.kept;
    p.launch(SeededRandom(widget.seed ^ (widget.throwId * 7919)), kept);
    ticker.stop();
    if (reduced) {
      p.settle(kept);
      return;
    }
    last = Duration.zero;
    carry = 0;
    ticker.start();
  }

  TrayPhysics bodyFor(BoxConstraints box) {
    final count = widget.session.settings.dice.length;
    final current = physics;
    if (current != null &&
        current.width == box.maxWidth &&
        current.height == box.maxHeight &&
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
    )..settle(const {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final session = widget.session;
    return LayoutBuilder(
      builder: (context, box) {
        final p = bodyFor(box);
        if (launched != widget.throwId && session.thrown) launch(p, reduced);
        return Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(Radii.lg),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Radii.lg),
            child: Stack(
              children: [
                if (session.thrown)
                  for (var i = 0; i < p.bodies.length; i++)
                    if (!session.kept.contains(i))
                      Positioned(
                        left: p.bodies[i].x - _dieSize / 2,
                        top: p.bodies[i].y - _dieSize / 2,
                        child: GestureDetector(
                          onTap: () => widget.onTapDie(i),
                          child: Transform.rotate(
                            angle: p.bodies[i].angle,
                            child: DieFace(
                              spec: session.settings.dice[i],
                              value: session.values[i],
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
