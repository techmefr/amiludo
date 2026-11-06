import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Sensors/sensor_sensitivity.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class SensorSensitivitySection extends StatelessWidget {
  const SensorSensitivitySection({
    super.key,
    required this.appearance,
    required this.change,
  });
  final Appearance appearance;
  final ValueChanged<Appearance> change;

  String _label(BuildContext context, SensorSensitivity level) {
    final l = context.l10n;
    return switch (level) {
      SensorSensitivity.off => l.appearanceSensorsOff,
      SensorSensitivity.low => l.appearanceSensorsLow,
      SensorSensitivity.medium => l.appearanceSensorsMedium,
      SensorSensitivity.high => l.appearanceSensorsHigh,
    };
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionHeading(context.l10n.appearanceMotionSensors),
      Wrap(
        spacing: Space.sm,
        runSpacing: Space.sm,
        children: [
          for (final level in SensorSensitivity.values)
            ChoiceChip(
              label: Text(_label(context, level)),
              selected: appearance.sensors == level.name,
              onSelected: (_) =>
                  change(appearance.copyWith(sensors: level.name)),
            ),
        ],
      ),
    ],
  );
}
