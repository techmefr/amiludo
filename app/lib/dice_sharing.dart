import 'package:flutter/widgets.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_library.dart';
import 'package:amiludo/layers/functional/Companion/domain/use_cases/die_share_use_cases.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_library_actions.dart';

Future<String> embedDice(String json) async =>
    getIt.isRegistered<EmbedDiceUseCase>()
    ? getIt<EmbedDiceUseCase>()(json)
    : json;

Future<String> acceptDice(BuildContext context, String text) async {
  if (!getIt.isRegistered<ReadEmbeddedDiceUseCase>()) return text;
  final found = getIt<ReadEmbeddedDiceUseCase>()(text);
  if (found == null) return text;
  final policy = found.clashes.isEmpty
      ? ClashPolicy.keepBoth
      : await askClashPolicy(context, found.clashes.length);
  if (policy == null) return text;
  return getIt<AcceptEmbeddedDiceUseCase>()(text, found.bundle, policy);
}
