import 'dart:async';

import 'package:amiludo/layers/technical/Motion/shake_source.dart';
import 'package:amiludo/layers/technical/Sensors/accelerometer_feed.dart';
import 'package:amiludo/layers/technical/Sensors/motion_detectors.dart';
import 'package:amiludo/layers/technical/Sensors/sensor_sensitivity.dart';

class AccelerometerShakeSource implements ShakeSource {
  AccelerometerShakeSource(
    this._feed,
    this._sensitivity, {
    this.clock = DateTime.now,
  });

  final AccelerometerFeed _feed;
  final SensorSensitivity _sensitivity;
  final DateTime Function() clock;

  @override
  Stream<void> get shakes {
    if (!_sensitivity.enabled) return const Stream.empty();
    final detector = ShakeDetector(threshold: _sensitivity.shakeThreshold);
    return _feed.samples
        .where((sample) => detector.add(sample, clock()))
        .map((_) {});
  }
}
