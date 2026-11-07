import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/atlas.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/cubit/notebook_cubit.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/name_dialog.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class AtlasTab extends StatelessWidget {
  const AtlasTab({super.key, required this.campaign});
  final NotebookCampaign campaign;

  Future<void> _add(BuildContext context, {String? parentId}) async {
    final l = context.l10n;
    final cubit = context.read<NotebookCubit>();
    final name = await showNameDialog(
      context,
      title: l.notebookNewPlace,
      label: l.notebookEntryName,
      action: l.notebookCreate,
    );
    if (name == null || name.trim().isEmpty) return;
    await cubit.addEntry(
      campaign.id,
      EntryKind.place,
      name,
      parentId: parentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final nodes = atlasTree(campaign);
    return ListView(
      padding: const EdgeInsets.all(Space.lg),
      children: [
        FilledButton.tonalIcon(
          onPressed: () => _add(context),
          icon: const Icon(Icons.add_location_alt_outlined),
          label: Text(l.notebookNewPlace),
        ),
        const SizedBox(height: Space.md),
        if (nodes.isEmpty) Text(l.notebookAtlasEmpty),
        for (final node in nodes)
          Padding(
            padding: EdgeInsetsDirectional.only(start: node.depth * Space.xl),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.place_outlined),
              title: Text(node.entry.name),
              onTap: () => context.push(
                '/notebook/${campaign.id}/entry/${node.entry.id}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: l.notebookNewPlace,
                    onPressed: () => _add(context, parentId: node.entry.id),
                    icon: const Icon(Icons.subdirectory_arrow_right),
                  ),
                  IconButton(
                    tooltip: l.notebookOpenMap,
                    onPressed: () => context.push(
                      '/notebook/${campaign.id}/map/${node.entry.id}',
                    ),
                    icon: const Icon(Icons.map_outlined),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
