import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Appearance/presentation/cubit/appearance_cubit.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/turn_sensor.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_page.dart';
import 'package:amiludo/layers/functional/Companion/presentation/hourglass_tool.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/technical/Motion/shake_source.dart';
import 'package:amiludo/layers/technical/Sensors/sensor_sensitivity.dart';

SensorSensitivity _level(Workspace state) =>
    SensorSensitivity.parse(state.appearance.sensors);

Widget _sensed(Widget Function(SensorSensitivity level) build) =>
    BlocSelector<AppearanceCubit, Workspace, SensorSensitivity>(
      selector: _level,
      builder: (context, level) => KeyedSubtree(
        key: ValueKey(level),
        child: build(level),
      ),
    );

ShakeSource _shakes(SensorSensitivity level) =>
    getIt.isRegistered<ShakeSource>()
    ? getIt<ShakeSource>(param1: level)
    : const NoShakeSource();

TurnSensor _turns(SensorSensitivity level) =>
    getIt.isRegistered<TurnSensor>()
    ? getIt<TurnSensor>(param1: level)
    : const NoTurnSensor();

Widget diceTrayWithSensors(BuildContext context) =>
    _sensed((level) => DiceTrayPage(shakeSource: _shakes(level)));

Widget hourglassWithSensors(BuildContext context) =>
    _sensed((level) => HourglassTool(sensor: _turns(level)));
