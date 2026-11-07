import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/entry_kinds.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/linked_field.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/rich_section_editors.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/section_editors.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

enum SectionMenu { rename, remove }

class EntrySectionCard extends StatelessWidget {
  const EntrySectionCard({
    super.key,
    required this.section,
    required this.entries,
    required this.onChange,
    required this.onRemove,
    required this.onOpen,
  });

  final EntrySection section;
  final List<NotebookEntry> entries;
  final SectionChange onChange;
  final VoidCallback onRemove;
  final ValueChanged<String> onOpen;

  Future<void> _rename(BuildContext context) async {
    final l = context.l10n;
    final controller = TextEditingController(text: section.title);
    final title = await showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l.notebookSectionTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: context.sectionTypeLabel(section.type),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: Text(l.themeCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, controller.text.trim()),
            child: Text(l.themeSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (title != null) onChange(section.copyWith(title: title));
  }

  Widget _editor(BuildContext context) => switch (section.type) {
    SectionType.description || SectionType.notes => LinkedField(
      text: section.text,
      entries: entries,
      hint: context.l10n.notebookLinkHint,
      onChanged: (v) => onChange(section.copyWith(text: v)),
      onOpen: onOpen,
    ),
    SectionType.checklist => ChecklistEditor(
      section: section,
      onChange: onChange,
    ),
    SectionType.tags => TagsEditor(section: section, onChange: onChange),
    SectionType.stats => StatsEditor(section: section, onChange: onChange),
    SectionType.pictures => PicturesEditor(
      section: section,
      onChange: onChange,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.sectionLabel(section),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                PopupMenuButton<SectionMenu>(
                  onSelected: (m) => switch (m) {
                    SectionMenu.rename => _rename(context),
                    SectionMenu.remove => onRemove(),
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: SectionMenu.rename,
                      child: Text(l.notebookSectionTitle),
                    ),
                    PopupMenuItem(
                      value: SectionMenu.remove,
                      child: Text(l.notebookRemove),
                    ),
                  ],
                ),
              ],
            ),
            _editor(context),
          ],
        ),
      ),
    );
  }
}
