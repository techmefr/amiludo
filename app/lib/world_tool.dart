import 'package:flutter/material.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Bestiary/domain/gateways/bestiary_gateway.dart';
import 'package:amiludo/layers/functional/Scenes/domain/gateways/storyline_gateway.dart';
import 'package:amiludo/layers/functional/World/domain/gateways/world_atlas_gateway.dart';
import 'package:amiludo/layers/functional/World/domain/use_cases/world_atlas_use_cases.dart';
import 'package:amiludo/layers/functional/World/presentation/world_tool.dart';

Map<String, String> _creatureNames() {
  if (!getIt.isRegistered<BestiaryGateway>()) return const {};
  return {
    for (final c in getIt<BestiaryGateway>().current.creatures) c.id: c.name,
  };
}

Map<String, String> _sceneNames() {
  if (!getIt.isRegistered<StorylineGateway>()) return const {};
  return {
    for (final s in getIt<StorylineGateway>().current.scenes) s.id: s.title,
  };
}

Widget worldWithStorage(BuildContext context) {
  if (!getIt.isRegistered<WorldAtlasGateway>()) return const WorldTool();
  return WorldTool(
    initial: getIt<ReadWorldAtlasUseCase>()(),
    onChanged: getIt<SaveWorldAtlasUseCase>().call,
    creatureNames: _creatureNames(),
    sceneNames: _sceneNames(),
  );
}
