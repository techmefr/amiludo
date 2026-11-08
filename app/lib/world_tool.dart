import 'package:flutter/material.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/World/domain/gateways/world_atlas_gateway.dart';
import 'package:amiludo/layers/functional/World/domain/use_cases/world_atlas_use_cases.dart';
import 'package:amiludo/layers/functional/World/presentation/world_tool.dart';

Widget worldWithStorage(BuildContext context) {
  if (!getIt.isRegistered<WorldAtlasGateway>()) return const WorldTool();
  return WorldTool(
    initial: getIt<ReadWorldAtlasUseCase>()(),
    onChanged: getIt<SaveWorldAtlasUseCase>().call,
  );
}
