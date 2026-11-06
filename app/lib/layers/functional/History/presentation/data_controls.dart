import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/History/presentation/cubit/history_cubit.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

class DataControls extends StatelessWidget {
  const DataControls();

  Future<void> _restore(BuildContext context) async {
    final controller = context.read<HistoryCubit>();
    try {
      final text = await FileTransfer.openJson();
      if (text == null || !context.mounted) return;
      if (!await confirm(
        context,
        context.l10n.historyRestoreBackup,
        context.l10n.historyYourCurrentLibraryWillBe,
      )) {
        return;
      }
      await controller.importBackup(text);
      if (context.mounted) {
        notify(context, context.l10n.historyBackupRestored);
      }
    } catch (error) {
      if (context.mounted) notify(context, 'Import impossible : $error');
    }
  }

  Future<void> _erase(BuildContext context) async {
    final controller = context.read<HistoryCubit>();
    if (await confirm(
      context,
      context.l10n.historyEraseAllData,
      context.l10n.historyGamesTemplatesProfilesAndSettings,
    )) {
      await controller.erase();
      if (context.mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionHeading(context.l10n.historyYourDataBelongsToYou),
      DeckPanel(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton(
              onPressed: () => FileTransfer.shareText(
                context.read<HistoryCubit>().exportBackup(),
                'compagnon-sauvegarde.json',
              ),
              child: Text(context.l10n.historyBackUpEverything),
            ),
            OutlinedButton(
              onPressed: () => _restore(context),
              child: Text(context.l10n.historyRestore),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      TextButton.icon(
        onPressed: () => _erase(context),
        icon: const DeckIcon(Icons.delete_forever_outlined),
        label: Text(context.l10n.historyEraseAllMyData),
      ),
    ],
  );
}
