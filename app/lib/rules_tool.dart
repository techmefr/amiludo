import 'package:flutter/material.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Rules/domain/gateways/rule_book_gateway.dart';
import 'package:amiludo/layers/functional/Rules/domain/use_cases/rule_book_use_cases.dart';
import 'package:amiludo/layers/functional/Rules/presentation/rules_tool.dart';

Widget rulesWithStorage(BuildContext context) {
  if (!getIt.isRegistered<RuleBookGateway>()) return const RulesTool();
  return RulesTool(
    initial: getIt<ReadRuleBookUseCase>()(),
    onChanged: getIt<SaveRuleBookUseCase>().call,
  );
}
