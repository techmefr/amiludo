import 'package:flutter/material.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Bestiary/domain/gateways/bestiary_gateway.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_map_pins.dart';
import 'package:amiludo/layers/functional/World/domain/gateways/world_atlas_gateway.dart';
import 'package:amiludo/layers/functional/Scenes/domain/gateways/storyline_gateway.dart';
import 'package:amiludo/layers/functional/Scenes/domain/use_cases/storyline_use_cases.dart';
import 'package:amiludo/layers/functional/Scenes/presentation/scenes_tool.dart';
import 'package:amiludo/layers/technical/Sound/ambient_output.dart';

Map<String, String> _creatureNames() {
  if (!getIt.isRegistered<BestiaryGateway>()) return const {};
  return {
    for (final c in getIt<BestiaryGateway>().current.creatures) c.id: c.name,
  };
}

Map<String, String> _placeNames() {
  if (!getIt.isRegistered<WorldAtlasGateway>()) return const {};
  return getIt<WorldAtlasGateway>().current.placeNamesByScene();
}

Widget scenesWithStorage(BuildContext context) {
  if (!getIt.isRegistered<StorylineGateway>()) return const ScenesTool();
  return ScenesTool(
    initial: getIt<ReadStorylineUseCase>()(),
    onChanged: getIt<SaveStorylineUseCase>().call,
    creatureNames: _creatureNames(),
    placeNames: _placeNames(),
    ambient: getIt.isRegistered<AmbientOutput>()
        ? getIt<AmbientOutput>()
        : const SilentAmbientOutput(),
  );
}
