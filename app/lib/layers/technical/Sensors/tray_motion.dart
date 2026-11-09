import 'dart:async';
import 'dart:math' as math;

import 'package:amiludo/layers/technical/Sensors/accelerometer_feed.dart';
import 'package:amiludo/layers/technical/Sensors/motion_detectors.dart';
import 'package:amiludo/layers/technical/Sensors/sensor_sensitivity.dart';

const double _earth = 9.80665;

class Tilt {
  const Tilt(this.x, this.y);

  static const Tilt flat = Tilt(0, 0);

  final double x, y;
}

abstract interface class TrayMotion {
  Stream<double> get throws;
  Stream<Tilt> get tilts;
}

class NoTrayMotion implements TrayMotion {
  const NoTrayMotion();

  @override
  Stream<double> get throws => const Stream.empty();

  @override
  Stream<Tilt> get tilts => const Stream.empty();
}

class ManualTrayMotion implements TrayMotion {
  final _throws = StreamController<double>.broadcast();
  final _tilts = StreamController<Tilt>.broadcast();

  @override
  Stream<double> get throws => _throws.stream;

  @override
  Stream<Tilt> get tilts => _tilts.stream;

  void throwWith(double strength) => _throws.add(strength);

  void tilt(Tilt value) => _tilts.add(value);

  Future<void> close() async {
    await _throws.close();
    await _tilts.close();
  }
}

Tilt tiltOf(AccelSample s) =>
    Tilt((-s.x / _earth).clamp(-1.0, 1.0), (s.y / _earth).clamp(-1.0, 1.0));

double strengthOf(AccelSample s, double threshold) {
  final magnitude = math.sqrt(s.x * s.x + s.y * s.y + s.z * s.z);
  return ((magnitude - _earth).abs() / (threshold * 3)).clamp(0.25, 1.5);
}

bool isFlick(AccelSample s, double threshold) =>
    s.y.abs() > threshold * 1.8 + _earth * 0.5 &&
    s.y.abs() > s.x.abs() * 2 &&
    s.y.abs() > s.z.abs();

class AccelerometerTrayMotion implements TrayMotion {
  AccelerometerTrayMotion(
    this._feed,
    this._sensitivity, {
    this.clock = DateTime.now,
  });

  final AccelerometerFeed _feed;
  final SensorSensitivity _sensitivity;
  final DateTime Function() clock;

  @override
  Stream<double> get throws {
    if (!_sensitivity.enabled) return const Stream.empty();
    final threshold = _sensitivity.shakeThreshold;
    final shake = ShakeDetector(threshold: threshold);
    DateTime? lastThrow;
    return _feed.samples.expand((sample) {
      final now = clock();
      final previous = lastThrow;
      if (previous != null && now.difference(previous) < shake.cooldown) {
        return const <double>[];
      }
      if (!shake.add(sample, now) && !isFlick(sample, threshold)) {
        return const <double>[];
      }
      lastThrow = now;
      return [strengthOf(sample, threshold)];
    });
  }

  @override
  Stream<Tilt> get tilts {
    if (!_sensitivity.enabled) return const Stream.empty();
    return _feed.samples.map(tiltOf);
  }
}
