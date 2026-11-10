import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/dice_studio.dart';
import 'package:amiludo/layers/functional/Appearance/presentation/cubit/appearance_cubit.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/turn_sensor.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_page.dart';
import 'package:amiludo/layers/functional/Companion/presentation/countdown_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/hourglass_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/turn_timer_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/metronome_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/phases_tool.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/technical/Motion/shake_source.dart';
import 'package:amiludo/layers/technical/Sensors/accelerometer_feed.dart';
import 'package:amiludo/layers/technical/Sensors/tray_motion.dart';
import 'package:amiludo/layers/technical/Sound/sound_output.dart';
import 'package:amiludo/layers/technical/Sensors/sensor_sensitivity.dart';
import 'package:amiludo/layers/functional/Random/presentation/coin_tool.dart';

SensorSensitivity _level(Workspace state) =>
    SensorSensitivity.parse(state.appearance.sensors);

Widget _sensed(Widget Function(SensorSensitivity level) build) =>
    BlocSelector<AppearanceCubit, Workspace, SensorSensitivity>(
      selector: _level,
      builder: (context, level) =>
          KeyedSubtree(key: ValueKey(level), child: build(level)),
    );

TurnSensor _turns(SensorSensitivity level) => getIt.isRegistered<TurnSensor>()
    ? getIt<TurnSensor>(param1: level)
    : const NoTurnSensor();

TrayMotion _motion(SensorSensitivity level) => getIt.isRegistered<TrayMotion>()
    ? getIt<TrayMotion>(param1: level)
    : const NoTrayMotion();

SoundOutput _sounds(bool enabled) =>
    enabled && getIt.isRegistered<SoundOutput>()
    ? getIt<SoundOutput>()
    : const SilentSoundOutput();

Widget diceTrayWithSensors(BuildContext context) {
  final appearance = context.read<AppearanceCubit>().state.appearance;
  return DieStudioHost(
    child: _sensed(
      (level) => DiceTrayPage(
        shakeSource: const NoShakeSource(),
        motion: _motion(level),
        showShakeHint: level.enabled && PlatformAccelerometerFeed.supported,
        requestMotionAccess:
            level.enabled && PlatformAccelerometerFeed.needsPermission
            ? PlatformAccelerometerFeed.requestPermission
            : null,
        soundOutput: _sounds(appearance.sound),
        sound: appearance.sound,
        haptics: appearance.haptics,
        solid: appearance.dice3d,
        onSolidChanged: (value) {
          final cubit = context.read<AppearanceCubit>();
          cubit.change(cubit.state.appearance.copyWith(dice3d: value));
        },
        skin: appearance.dieSkin,
        table: appearance.table,
        onSkinChanged: (id) {
          final cubit = context.read<AppearanceCubit>();
          cubit.change(cubit.state.appearance.copyWith(dieSkin: id));
        },
        onTableChanged: (id) {
          final cubit = context.read<AppearanceCubit>();
          cubit.change(cubit.state.appearance.copyWith(table: id));
        },
      ),
    ),
  );
}

Widget countdownWithFeedback(BuildContext context) {
  final appearance = context.read<AppearanceCubit>().state.appearance;
  return CountdownTool(sound: appearance.sound, haptics: appearance.haptics);
}

Widget turnTimerWithFeedback(BuildContext context) {
  final appearance = context.read<AppearanceCubit>().state.appearance;
  return TurnTimerTool(sound: appearance.sound, haptics: appearance.haptics);
}

Widget metronomeWithFeedback(BuildContext context) {
  final appearance = context.read<AppearanceCubit>().state.appearance;
  return MetronomeTool(sound: appearance.sound, haptics: appearance.haptics);
}

Widget phasesWithFeedback(BuildContext context) {
  final appearance = context.read<AppearanceCubit>().state.appearance;
  return PhasesTool(sound: appearance.sound, haptics: appearance.haptics);
}

Widget hourglassWithSensors(BuildContext context) => _sensed(
  (level) => HourglassTool(
    sensor: _turns(level),
    requestMotionAccess:
        level.enabled && PlatformAccelerometerFeed.needsPermission
        ? PlatformAccelerometerFeed.requestPermission
        : null,
  ),
);

Widget coinWithSensors(BuildContext context) {
  final appearance = context.read<AppearanceCubit>().state.appearance;
  return DieStudioHost(
    child: _sensed(
      (level) => CoinTool(motion: _motion(level), haptics: appearance.haptics),
    ),
  );
}
