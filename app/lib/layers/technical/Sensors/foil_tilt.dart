import 'dart:ui';

import 'package:amiludo/layers/technical/Sensors/accelerometer_feed.dart';

const double _gravity = 9.80665;

Offset foilTiltFromSample(AccelSample sample) => Offset(
  (.5 + sample.x / _gravity * .5).clamp(0.0, 1.0),
  (.5 - sample.y / _gravity * .5).clamp(0.0, 1.0),
);
