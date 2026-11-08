import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Sound/ambient_sounds.dart';

AmbientKind? ambienceKind(String? name) =>
    AmbientKind.values.where((k) => k.name == name).firstOrNull;

String ambienceLabel(BuildContext context, AmbientKind kind) {
  final l = context.l10n;
  return switch (kind) {
    AmbientKind.rain => l.ambienceRain,
    AmbientKind.wind => l.ambienceWind,
    AmbientKind.fire => l.ambienceFire,
    AmbientKind.storm => l.ambienceStorm,
  };
}

IconData ambienceIcon(AmbientKind kind) => switch (kind) {
  AmbientKind.rain => Icons.water_drop_outlined,
  AmbientKind.wind => Icons.air,
  AmbientKind.fire => Icons.local_fire_department_outlined,
  AmbientKind.storm => Icons.thunderstorm_outlined,
};
