import 'package:flutter/material.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Tables/domain/gateways/roll_tables_gateway.dart';
import 'package:amiludo/layers/functional/Tables/domain/use_cases/roll_tables_use_cases.dart';
import 'package:amiludo/layers/functional/Tables/presentation/tables_tool.dart';

Widget tablesWithStorage(BuildContext context) {
  if (!getIt.isRegistered<RollTablesGateway>()) return const TablesTool();
  return TablesTool(
    initial: getIt<ReadRollTablesUseCase>()(),
    onChanged: getIt<SaveRollTablesUseCase>().call,
  );
}
