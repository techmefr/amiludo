import 'package:amiludo/layers/technical/Physics/seeded_random.dart';
import 'package:amiludo/layers/technical/Physics/tray_physics.dart';

List<int> throwTray(
  TrayPhysics physics, {
  required int seed,
  required Set<int> kept,
  required List<int> sides,
  required double power,
  double aimX = 0,
  double aimY = 0,
}) {
  void launch(TrayPhysics p) => p.launch(
    SeededRandom(seed),
    kept,
    power: power,
    sides: sides,
    aimX: aimX,
    aimY: aimY,
  );
  final rehearsal = physics.copy();
  launch(rehearsal);
  rehearsal.settle(kept);
  launch(physics);
  return rehearsal.outcome();
}

void settleQuietly(
  TrayPhysics physics,
  Set<int> kept,
  void Function(TrayImpact impact)? onImpact,
) {
  physics.onImpact = null;
  physics.settle(kept);
  physics.onImpact = onImpact;
}
