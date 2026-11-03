import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/templates_cubit.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/game_setup_request.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});
  Future<void> create(BuildContext context) async {
    context.push('/builder/new');
  }

  Future<void> importTemplate(BuildContext context) async {
    final templates = context.read<TemplatesCubit>();
    try {
      final text = await FileTransfer.openJson();
      if (text == null) return;
      final data = Map<String, dynamic>.from(jsonDecode(text) as Map);
      if (data['format'] != 'table-companion-template' ||
          data['version'] != 1) {
        throw const FormatException('Format de modèle incompatible');
      }
      final template = GameTemplate.fromJson(
        Map<String, dynamic>.from(data['template'] as Map),
      );
      if (GameTemplate.builtIn.any((t) => t.id == template.id)) {
        throw const FormatException('Identifiant réservé à un modèle intégré');
      }
      await templates.addTemplate(template);
      if (context.mounted) {
        notify(context, tr(context, 'Modèle importé', 'Template imported'));
      }
    } catch (error) {
      if (context.mounted) notify(context, 'Import impossible : $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ws = context.watch<TemplatesCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeckHeading(
          eyebrow: tr(
            context,
            'Vos règles / vos parties',
            'Your rules / your games',
          ),
          title: tr(context, 'Vos compagnons de jeu', 'Your game companions'),
          subtitle: tr(
            context,
            'Vos packs réunissent dés, rôles, décompte et références de règles.',
            'These templates configure scores, targets and timers.',
          ),
          action: FilledButton.icon(
            onPressed: () => create(context),
            icon: const DeckIcon(Icons.add),
            label: Text(tr(context, 'Créer un compagnon', 'Create companion')),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.push('/marketplace'),
                icon: const DeckIcon(Icons.storefront_outlined),
                label: const Text('Galerie communautaire'),
              ),
              OutlinedButton.icon(
                onPressed: () => importTemplate(context),
                icon: const DeckIcon(Icons.file_open_outlined),
                label: Text(
                  tr(
                    context,
                    'Importer un modèle JSON',
                    'Import JSON template',
                  ),
                ),
              ),
            ],
          ),
        ),
        ResponsiveGrid(
          minimumWidth: 250,
          children: [...GameTemplate.builtIn, ...ws.templates]
              .map(
                (t) => DeckPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DeckIcon(
                        t.cooperative
                            ? Icons.groups_outlined
                            : t.lowestWins
                            ? Icons.south
                            : Icons.dashboard_outlined,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        t.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(t.description),
                      const SizedBox(height: 16),
                      Text(
                        '${t.categories.join(' / ')} · ${t.seconds}s',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (t.target > 0) Text('Objectif / ${t.target}'),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () => context.push(
                          GameSetupRequest.path,
                          extra: GameSetupRequest(template: t),
                        ),
                        child: Text(
                          tr(context, 'Jouer avec ce modèle', 'Use template'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          TextButton(
                            onPressed: () => context.push('/builder/${t.id}'),
                            child: Text(
                              ws.templates.any((v) => v.id == t.id)
                                  ? 'Modifier'
                                  : 'Copier dans mon atelier',
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/pack/${t.id}'),
                            child: const Text('Outils et règles du pack'),
                          ),
                          TextButton(
                            onPressed: () => FileTransfer.shareText(
                              jsonEncode({
                                'format': 'table-companion-template',
                                'version': 1,
                                'template': t.toJson(),
                              }),
                              'modele-${t.id}.json',
                            ),
                            child: Text(tr(context, 'Partager', 'Share')),
                          ),
                          if (ws.templates.any((custom) => custom.id == t.id))
                            TextButton(
                              onPressed: () async {
                                final templates = context
                                    .read<TemplatesCubit>();
                                if (await confirm(
                                  context,
                                  tr(
                                    context,
                                    'Supprimer le modèle ?',
                                    'Delete template?',
                                  ),
                                  t.name,
                                )) {
                                  await templates.removeTemplate(t.id);
                                }
                              },
                              child: Text(tr(context, 'Supprimer', 'Delete')),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
