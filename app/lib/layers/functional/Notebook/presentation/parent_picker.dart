import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/atlas.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class ParentPicker extends StatelessWidget {
  const ParentPicker({
    super.key,
    required this.campaign,
    required this.entry,
    required this.onChanged,
  });

  final NotebookCampaign campaign;
  final NotebookEntry entry;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final candidates = parentCandidates(campaign, entry.id);
    final current = candidates.any((p) => p.id == entry.parentId)
        ? entry.parentId
        : null;
    return DropdownButtonFormField<String?>(
      initialValue: current,
      isExpanded: true,
      decoration: InputDecoration(labelText: l.notebookParentPlace),
      items: [
        DropdownMenuItem(value: null, child: Text(l.notebookNoParent)),
        for (final p in candidates)
          DropdownMenuItem(value: p.id, child: Text(p.name)),
      ],
      onChanged: onChanged,
    );
  }
}
