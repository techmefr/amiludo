import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

IconData entryIcon(EntryKind kind) => switch (kind) {
  EntryKind.npc => Icons.person_outline,
  EntryKind.place => Icons.place_outlined,
  EntryKind.quest => Icons.flag_outlined,
  EntryKind.loot => Icons.diamond_outlined,
  EntryKind.faction => Icons.groups_outlined,
};

extension EntryTexts on BuildContext {
  String kindLabel(EntryKind kind) => switch (kind) {
    EntryKind.npc => l10n.notebookKindNpc,
    EntryKind.place => l10n.notebookKindPlace,
    EntryKind.quest => l10n.notebookKindQuest,
    EntryKind.loot => l10n.notebookKindLoot,
    EntryKind.faction => l10n.notebookKindFaction,
  };

  String sectionLabel(EntrySection section) {
    if (section.title.isNotEmpty) return section.title;
    return switch (section.type) {
      SectionType.description => l10n.notebookSectionDescription,
      SectionType.notes => l10n.notebookSectionNotes,
      SectionType.checklist => l10n.notebookSectionChecklist,
      SectionType.tags => l10n.notebookSectionTags,
      SectionType.stats => l10n.notebookSectionStats,
      SectionType.pictures => l10n.notebookSectionPictures,
    };
  }

  String sectionTypeLabel(SectionType type) =>
      sectionLabel(EntrySection(id: '', type: type));
}
