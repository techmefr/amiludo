import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/campaign_card.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/campaign_look_sheet.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/cubit/notebook_cubit.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/new_campaign_sheet.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class CampaignsScreen extends StatelessWidget {
  const CampaignsScreen({
    super.key,
    this.pickFile = FileTransfer.openJson,
    this.shareFile = FileTransfer.shareText,
  });

  final Future<String?> Function() pickFile;
  final Future<void> Function(String text, String filename) shareFile;

  Future<void> _import(BuildContext context) async {
    final cubit = context.read<NotebookCubit>();
    final l = context.l10n;
    try {
      final source = await pickFile();
      if (source == null) return;
      await cubit.importFile(source);
      if (context.mounted) notify(context, l.notebookImported);
    } on FormatException {
      if (context.mounted) notify(context, l.notebookImportFailed);
    }
  }

  Future<void> _export(BuildContext context, NotebookCampaign c) async {
    final text = await context.read<NotebookCubit>().export(c.id);
    await shareFile(text, '${c.title.trim().replaceAll(' ', '-')}.json');
  }

  Future<void> _delete(BuildContext context, NotebookCampaign c) async {
    final l = context.l10n;
    final cubit = context.read<NotebookCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l.notebookDeleteAsk(c.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(l.themeCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l.notebookDelete),
          ),
        ],
      ),
    );
    if (ok == true) await cubit.delete(c.id);
  }

  Future<void> _create(BuildContext context) async {
    final cubit = context.read<NotebookCubit>();
    final router = GoRouter.of(context);
    final draft = await showNewCampaignSheet(context);
    if (draft == null) return;
    final id = await cubit.create(draft.title, draft.kind);
    router.push('/notebook/$id');
  }

  void _act(BuildContext context, NotebookCampaign c, CampaignAction a) =>
      switch (a) {
        CampaignAction.look => showCampaignLookSheet(context, c.id),
        CampaignAction.export => _export(context, c),
        CampaignAction.delete => _delete(context, c),
      };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final Notebook notebook = context.watch<NotebookCubit>().state;
    final cubit = context.read<NotebookCubit>();
    return FullPage(
      title: l.notebookTitle,
      fallback: '/',
      actions: [
        IconButton(
          tooltip: l.notebookImport,
          onPressed: () => _import(context),
          icon: const Icon(Icons.file_open_outlined),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.notebookIntro, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: Space.lg),
          FilledButton.icon(
            onPressed: () => _create(context),
            icon: const Icon(Icons.add),
            label: Text(l.notebookNewCampaign),
          ),
          const SizedBox(height: Space.lg),
          if (notebook.isEmpty)
            EmptyPanel(
              icon: Icons.menu_book_outlined,
              title: l.notebookEmpty,
              message: l.notebookEmptyHint,
            )
          else
            ResponsiveGrid(
              minimumWidth: 280,
              children: [
                for (final c in notebook.sorted)
                  CampaignCard(
                    campaign: c,
                    onOpen: () => context.push('/notebook/${c.id}'),
                    onFavorite: () => cubit.toggleFavorite(c.id),
                    onAction: (a) => _act(context, c, a),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
