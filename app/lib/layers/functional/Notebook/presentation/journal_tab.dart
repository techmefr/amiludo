import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/journal.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/cubit/notebook_cubit.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/journal_toolbar.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/linked_text.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

IconData journalIcon(JournalKind kind) => switch (kind) {
  JournalKind.note => Icons.edit_note,
  JournalKind.dice => Icons.casino_outlined,
  JournalKind.oracle => Icons.help_outline,
  JournalKind.generator => Icons.auto_awesome_outlined,
  JournalKind.scene => Icons.theaters_outlined,
};

class JournalTab extends StatelessWidget {
  const JournalTab({super.key, required this.campaign});
  final NotebookCampaign campaign;

  Future<void> _start(BuildContext context) async {
    final l = context.l10n;
    final cubit = context.read<NotebookCubit>();
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l.notebookStartSession),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l.notebookSessionTitle),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: Text(l.themeCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, controller.text),
            child: Text(l.notebookStartSession),
          ),
        ],
      ),
    );
    controller.dispose();
    if (title != null) await cubit.startSession(campaign.id, title);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cubit = context.read<NotebookCubit>();
    final theme = Theme.of(context);
    final sessions = campaign.sessions.reversed.toList();
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(Space.lg),
            children: [
              Wrap(
                spacing: Space.sm,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => _start(context),
                    icon: const Icon(Icons.play_arrow),
                    label: Text(l.notebookStartSession),
                  ),
                  if (campaign.activeSession != null)
                    OutlinedButton.icon(
                      onPressed: () => cubit.endSession(campaign.id),
                      icon: const Icon(Icons.stop),
                      label: Text(l.notebookEndSession),
                    ),
                ],
              ),
              if (sessions.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(Space.xl),
                  child: Text(l.notebookJournalEmpty),
                ),
              for (final session in sessions) ...[
                Padding(
                  padding: const EdgeInsets.only(top: Space.xl),
                  child: Text(
                    '${session.title.isEmpty ? l.notebookSession : session.title}'
                    ' · ${MaterialLocalizations.of(context).formatShortDate(session.startedAt)}'
                    '${session.active ? ' · ${l.notebookSessionActive}' : ''}',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                for (final line in session.lines)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(journalIcon(line.kind)),
                    title: LinkedText(
                      text: line.text,
                      entries: campaign.entries,
                      onOpen: (id) =>
                          context.push('/notebook/${campaign.id}/entry/$id'),
                    ),
                    subtitle: Text(
                      TimeOfDay.fromDateTime(line.at).format(context),
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: PopupMenuButton<void>(
                      tooltip: l.notebookRemove,
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          onTap: () => cubit.removeLine(
                            campaign.id,
                            session.id,
                            line.id,
                          ),
                          child: Text(l.notebookRemove),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
        JournalToolbar(
          chaos: campaign.chaos,
          onChaos: (v) =>
              cubit.update(campaign.id, (c) => c.copyWith(chaos: v)),
          onLine: (kind, text) => cubit.addLine(campaign.id, kind, text),
        ),
      ],
    );
  }
}
