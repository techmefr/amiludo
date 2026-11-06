import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/die_bundle.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_library.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_studio.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

void _say(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

Future<void> exportDice(
  BuildContext context,
  DieStudioCubit cubit,
  List<String> ids,
) async {
  final text = await cubit.export(ids);
  await FileTransfer.shareText(text, 'amiludo-dice.json');
}

Future<ClashPolicy?> askClashPolicy(BuildContext context, int count) {
  final l = context.l10n;
  return showDialog<ClashPolicy>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(l.diceImportClashTitle),
      content: Text(l.diceImportClashBody(count)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, ClashPolicy.keepBoth),
          child: Text(l.diceImportKeepBoth),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, ClashPolicy.replace),
          child: Text(l.diceImportReplace),
        ),
      ],
    ),
  );
}

Future<void> importDice(BuildContext context, DieStudioCubit cubit) async {
  final l = context.l10n;
  DieBundle bundle;
  Set<String> clashes;
  try {
    final text = await FileTransfer.openJson(maxMegabytes: 5);
    if (text == null) return;
    final preview = cubit.previewImport(text);
    bundle = preview.bundle;
    clashes = preview.clashes;
  } on Object {
    if (context.mounted) _say(context, l.diceImportFailed);
    return;
  }
  if (!context.mounted) return;
  final policy = clashes.isEmpty
      ? ClashPolicy.keepBoth
      : await askClashPolicy(context, clashes.length);
  if (policy == null) return;
  await cubit.import(bundle, policy);
  if (context.mounted) _say(context, l.diceImported);
}
