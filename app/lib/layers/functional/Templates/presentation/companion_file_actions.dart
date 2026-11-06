import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/dice_sharing.dart';
import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/companion_file.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/templates_cubit.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

String companionProblemText(AppLocalizations l, CompanionFileProblem p) =>
    switch (p) {
    CompanionFileProblem.notJson => l.companionErrorNotJson,
    CompanionFileProblem.wrongFormat => l.companionErrorFormat,
    CompanionFileProblem.wrongVersion => l.companionErrorVersion,
    CompanionFileProblem.invalid => l.companionErrorInvalid,
    CompanionFileProblem.reserved => l.companionErrorReserved,
  };

Future<void> shareCompanionFile(GameTemplate template) async =>
    FileTransfer.shareText(
      await embedDice(CompanionFile.encode(template)),
      'companion-${template.id}.json',
    );

Future<void> importCompanionFile(BuildContext context) async {
  final templates = context.read<TemplatesCubit>();
  final l = context.l10n;
  String message;
  try {
    final text = await FileTransfer.openJson();
    if (text == null) return;
    if (!context.mounted) return;
    final accepted = await acceptDice(context, text);
    await templates.addTemplate(CompanionFile.decode(accepted));
    message = l.templatesCompanionImported;
  } on CompanionFileException catch (error) {
    message = companionProblemText(l, error.problem);
  } on FormatException {
    message = l.companionErrorInvalid;
  }
  if (context.mounted) notify(context, message);
}
