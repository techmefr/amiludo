import 'dart:async';

import 'package:amiludo/layers/technical/Sensors/accelerometer_feed.dart';
import 'package:amiludo/layers/technical/Sensors/motion_detectors.dart';
import 'package:amiludo/layers/technical/Sensors/sensor_sensitivity.dart';

class AccelerometerTurns {
  AccelerometerTurns(
    this._feed,
    this._sensitivity, {
    this.clock = DateTime.now,
  });

  final AccelerometerFeed _feed;
  final SensorSensitivity _sensitivity;
  final DateTime Function() clock;

  Stream<void> get turns {
    if (!_sensitivity.enabled) return const Stream.empty();
    final detector = TurnDetector();
    return _feed.samples
        .where((sample) => detector.add(sample, clock()))
        .map((_) {});
  }
}
