import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/entry_links.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/campaign_theme.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/cubit/notebook_cubit.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/entry_kinds.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/entry_section_card.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/linked_text.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/parent_picker.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class EntryScreen extends StatelessWidget {
  const EntryScreen({
    super.key,
    required this.campaignId,
    required this.entryId,
  });
  final String campaignId, entryId;

  @override
  Widget build(BuildContext context) => CampaignScope(
    id: campaignId,
    builder: (context, campaign) {
      final entry = campaign.entry(entryId);
      if (entry == null) return const Scaffold();
      return _EntryView(
        key: ValueKey(entryId),
        campaign: campaign,
        initial: entry,
      );
    },
  );
}

class _EntryView extends StatefulWidget {
  const _EntryView({super.key, required this.campaign, required this.initial});
  final NotebookCampaign campaign;
  final NotebookEntry initial;

  @override
  State<_EntryView> createState() => _EntryViewState();
}

class _EntryViewState extends State<_EntryView> {
  late NotebookEntry entry = widget.initial;
  late final name = TextEditingController(text: entry.name);

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void save(NotebookEntry next) {
    setState(() => entry = next);
    context.read<NotebookCubit>().saveEntry(widget.campaign.id, next);
  }

  void changeSection(EntrySection next) => save(
    entry.copyWith(
      sections: [for (final s in entry.sections) s.id == next.id ? next : s],
    ),
  );

  void open(String id) =>
      context.push('/notebook/${widget.campaign.id}/entry/$id');

  Future<void> remove() async {
    final cubit = context.read<NotebookCubit>();
    final router = GoRouter.of(context);
    await cubit.removeEntry(widget.campaign.id, entry.id);
    if (router.canPop()) router.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final links = backlinks(widget.campaign, entry.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.kindLabel(entry.kind)),
        actions: [
          PopupMenuButton<SectionType>(
            tooltip: l.notebookAddSection,
            icon: const Icon(Icons.playlist_add),
            onSelected: (type) => save(
              entry.copyWith(
                sections: [
                  ...entry.sections,
                  EntrySection(id: notebookId(), type: type),
                ],
              ),
            ),
            itemBuilder: (_) => [
              for (final t in SectionType.values)
                PopupMenuItem(
                  value: t,
                  child: Text(context.sectionTypeLabel(t)),
                ),
            ],
          ),
          IconButton(
            tooltip: l.notebookDelete,
            onPressed: remove,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.lg),
        children: [
          TextField(
            controller: name,
            style: theme.textTheme.headlineSmall,
            decoration: InputDecoration(hintText: l.notebookEntryName),
            onChanged: (v) => save(entry.copyWith(name: v)),
          ),
          const SizedBox(height: Space.md),
          if (entry.kind == EntryKind.place)
            ParentPicker(
              campaign: widget.campaign,
              entry: entry,
              onChanged: (parent) => save(
                parent == null
                    ? entry.withoutParent()
                    : entry.copyWith(parentId: parent),
              ),
            ),
          for (final section in entry.sections)
            EntrySectionCard(
              key: ValueKey(section.id),
              section: section,
              entries: [
                for (final e in widget.campaign.entries)
                  if (e.id != entry.id) e,
              ],
              onChange: changeSection,
              onOpen: open,
              onRemove: () => save(
                entry.copyWith(
                  sections: [
                    for (final s in entry.sections)
                      if (s.id != section.id) s,
                  ],
                ),
              ),
            ),
          if (links.entries.isNotEmpty || links.lines.isNotEmpty) ...[
            const SizedBox(height: Space.lg),
            Text(l.notebookBacklinks, style: theme.textTheme.titleMedium),
            for (final e in links.entries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(entryIcon(e.kind)),
                title: Text(e.name),
                onTap: () => open(e.id),
              ),
            for (final line in links.lines)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.edit_note),
                title: LinkedText(
                  text: line,
                  entries: widget.campaign.entries,
                  onOpen: open,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
