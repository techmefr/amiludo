import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_search.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/cubit/notebook_cubit.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/entry_kinds.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/journal_tab.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/new_entry_dialog.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class EntriesTab extends StatefulWidget {
  const EntriesTab({super.key, required this.campaign});
  final NotebookCampaign campaign;

  @override
  State<EntriesTab> createState() => _EntriesTabState();
}

class _EntriesTabState extends State<EntriesTab> {
  String query = '';
  EntryKind? filter;

  Future<void> create() async {
    final cubit = context.read<NotebookCubit>();
    final router = GoRouter.of(context);
    final draft = await showNewEntryDialog(context);
    if (draft == null) return;
    final id = await cubit.addEntry(widget.campaign.id, draft.kind, draft.name);
    router.push('/notebook/${widget.campaign.id}/entry/$id');
  }

  void open(String entryId) =>
      context.push('/notebook/${widget.campaign.id}/entry/$entryId');

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final campaign = widget.campaign;
    final searching = query.trim().isNotEmpty;
    final entries = [
      for (final e in campaign.entries)
        if (filter == null || e.kind == filter) e,
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return ListView(
      padding: const EdgeInsets.all(Space.lg),
      children: [
        TextField(
          onChanged: (v) => setState(() => query = v),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: l.notebookSearchHint,
          ),
        ),
        const SizedBox(height: Space.md),
        if (!searching)
          Wrap(
            spacing: Space.sm,
            children: [
              ChoiceChip(
                label: Text(l.notebookAll),
                selected: filter == null,
                onSelected: (_) => setState(() => filter = null),
              ),
              for (final kind in EntryKind.values)
                ChoiceChip(
                  label: Text(context.kindLabel(kind)),
                  selected: filter == kind,
                  onSelected: (_) => setState(() => filter = kind),
                ),
            ],
          ),
        const SizedBox(height: Space.md),
        FilledButton.tonalIcon(
          onPressed: create,
          icon: const Icon(Icons.add),
          label: Text(l.notebookNewEntry),
        ),
        const SizedBox(height: Space.md),
        if (searching) ..._results(context) else ..._list(context, entries),
      ],
    );
  }

  List<Widget> _results(BuildContext context) {
    final hits = searchCampaign(widget.campaign, query);
    if (hits.isEmpty) return [Text(context.l10n.notebookNoResults)];
    return [
      for (final hit in hits)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            hit.entry == null
                ? journalIcon(hit.line!.kind)
                : entryIcon(hit.entry!.kind),
          ),
          title: Text(hit.entry?.name ?? hit.snippet),
          subtitle: hit.entry == null ? null : Text(hit.snippet),
          onTap: hit.entry == null ? null : () => open(hit.entry!.id),
        ),
    ];
  }

  List<Widget> _list(BuildContext context, List<NotebookEntry> entries) {
    if (entries.isEmpty) return [Text(context.l10n.notebookEntriesEmpty)];
    return [
      for (final e in entries)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(entryIcon(e.kind)),
          title: Text(e.name),
          subtitle: Text(context.kindLabel(e.kind)),
          onTap: () => open(e.id),
        ),
    ];
  }
}
