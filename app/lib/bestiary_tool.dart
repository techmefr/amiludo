import 'package:flutter/material.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Bestiary/domain/gateways/bestiary_gateway.dart';
import 'package:amiludo/layers/functional/Bestiary/domain/use_cases/bestiary_use_cases.dart';
import 'package:amiludo/layers/functional/Bestiary/presentation/bestiary_tool.dart';

Widget bestiaryWithStorage(BuildContext context) {
  if (!getIt.isRegistered<BestiaryGateway>()) return const BestiaryTool();
  return BestiaryTool(
    initial: getIt<ReadBestiaryUseCase>()(),
    onChanged: getIt<SaveBestiaryUseCase>().call,
  );
}
