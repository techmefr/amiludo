import 'package:amiludo/layers/technical/Physics/tray_physics.dart';

const int _maxSteps = 400;

class FixedStepper {
  Duration _last = Duration.zero;
  double _carry = 0;

  void reset() {
    _last = Duration.zero;
    _carry = 0;
  }

  void advance(TrayPhysics physics, Duration elapsed, Set<int> kept) {
    _carry += (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    var steps = 0;
    while (_carry >= TrayPhysics.step && steps++ < _maxSteps) {
      physics.advance(TrayPhysics.step, kept);
      _carry -= TrayPhysics.step;
    }
  }
}
