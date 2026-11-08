import 'package:flutter/material.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Journal/domain/gateways/game_log_gateway.dart';
import 'package:amiludo/layers/functional/Journal/domain/use_cases/game_log_use_cases.dart';
import 'package:amiludo/layers/functional/Journal/presentation/journal_tool.dart';

Widget journalWithStorage(BuildContext context) {
  if (!getIt.isRegistered<GameLogGateway>()) return const JournalTool();
  return JournalTool(
    initial: getIt<ReadGameLogUseCase>()(),
    onChanged: getIt<SaveGameLogUseCase>().call,
  );
}
