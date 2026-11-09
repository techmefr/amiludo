import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'browser_motion_stub.dart'
    if (dart.library.js_interop) 'browser_motion_web.dart';

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

  static bool get supported => kIsWeb
      ? BrowserMotion.supported
      : defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS;

  static bool get needsPermission => kIsWeb && BrowserMotion.needsPermission;
  static Future<bool> requestPermission() => BrowserMotion.requestPermission();

  @override
  Stream<AccelSample> get samples {
    if (!supported) return const Stream.empty();
    if (kIsWeb) {
      return BrowserMotion.samples().map((sample) {
        final (x, y, z) = sample;
        return AccelSample(x, y, z);
      });
    }
    return accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
        .map((event) => AccelSample(event.x, event.y, event.z));
  }
}
