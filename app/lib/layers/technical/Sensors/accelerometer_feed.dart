import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AccelSample {
  const AccelSample(this.x, this.y, this.z);

  final double x, y, z;
}

abstract interface class AccelerometerFeed {
  Stream<AccelSample> get samples;
}

class NoAccelerometerFeed implements AccelerometerFeed {
  const NoAccelerometerFeed();

  @override
  Stream<AccelSample> get samples => const Stream.empty();
}

class PlatformAccelerometerFeed implements AccelerometerFeed {
  const PlatformAccelerometerFeed();

  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Stream<AccelSample> get samples {
    if (!supported) return const Stream.empty();
    return accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
        .map((event) => AccelSample(event.x, event.y, event.z));
  }
}
