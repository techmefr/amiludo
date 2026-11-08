import 'package:flutter/material.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Companion/presentation/ambience_tool.dart';
import 'package:amiludo/layers/technical/Sound/ambient_output.dart';

Widget ambienceWithSound(BuildContext context) => AmbienceTool(
  output: getIt.isRegistered<AmbientOutput>()
      ? getIt<AmbientOutput>()
      : const SilentAmbientOutput(),
);
