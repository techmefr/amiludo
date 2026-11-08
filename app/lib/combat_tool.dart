import 'package:flutter/material.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Combat/domain/gateways/encounter_gateway.dart';
import 'package:amiludo/layers/functional/Combat/domain/use_cases/encounter_use_cases.dart';
import 'package:amiludo/layers/functional/Combat/presentation/combat_tool.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';
import 'package:amiludo/layers/functional/Notebook/domain/gateways/notebook_gateways.dart';

List<String> _npcNames() {
  if (!getIt.isRegistered<NotebookGateway>()) return const [];
  final names = <String>{
    for (final campaign in getIt<NotebookGateway>().current.campaigns)
      for (final entry in campaign.entries)
        if (entry.kind == EntryKind.npc && entry.name.trim().isNotEmpty)
          entry.name.trim(),
  };
  return names.toList();
}

Widget combatWithStorage(BuildContext context) {
  if (!getIt.isRegistered<EncounterGateway>()) return const CombatTool();
  return CombatTool(
    initial: getIt<ReadEncounterUseCase>()(),
    onChanged: getIt<SaveEncounterUseCase>().call,
    npcNames: _npcNames(),
  );
}
