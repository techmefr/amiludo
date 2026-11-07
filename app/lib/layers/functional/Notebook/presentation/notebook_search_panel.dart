import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_wide_search.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/entry_kinds.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/journal_tab.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class NotebookSearchPanel extends StatefulWidget {
  const NotebookSearchPanel({
    super.key,
    required this.notebook,
    required this.fallback,
  });

  final Notebook notebook;
  final Widget fallback;

  @override
  State<NotebookSearchPanel> createState() => _NotebookSearchPanelState();
}

class _NotebookSearchPanelState extends State<NotebookSearchPanel> {
  var query = '';

  void _open(CampaignHit result) {
    final entry = result.hit.entry;
    context.push(
      entry == null
          ? '/notebook/${result.campaign.id}'
          : '/notebook/${result.campaign.id}/entry/${entry.id}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final searching = query.trim().isNotEmpty;
    final results = searching
        ? searchNotebook(widget.notebook, query)
        : const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.notebook.isEmpty) ...[
          TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l.notebookSearchAll,
            ),
          ),
          const SizedBox(height: Space.lg),
        ],
        if (!searching)
          widget.fallback
        else if (results.isEmpty)
          Text(l.notebookNoResults)
        else
          for (final r in results)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                r.hit.entry == null
                    ? journalIcon(r.hit.line!.kind)
                    : entryIcon(r.hit.entry!.kind),
              ),
              title: Text(r.hit.entry?.name ?? r.hit.snippet),
              subtitle: Text(
                r.hit.entry == null
                    ? r.campaign.title
                    : '${r.campaign.title} · ${r.hit.snippet}',
              ),
              onTap: () => _open(r),
            ),
      ],
    );
  }
}
