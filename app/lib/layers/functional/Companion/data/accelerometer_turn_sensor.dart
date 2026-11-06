import 'dart:async';

import 'package:amiludo/layers/functional/Companion/domain/entities/turn_sensor.dart';
import 'package:amiludo/layers/technical/Sensors/accelerometer_turns.dart';

class AccelerometerTurnSensor implements TurnSensor {
  const AccelerometerTurnSensor(this._turns);

  final AccelerometerTurns _turns;

  @override
  Stream<void> get turns => _turns.turns;
}
