import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../technical/Theme/deck_widgets.dart';
import '../../../technical/Files/file_transfer.dart';
import '../../Workspace/workspace_controller.dart';
import '../../Workspace/presentation/game_setup.dart';
import '../domain/game_template.dart';

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});
  Future<void> create(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController(),
        description = TextEditingController(),
        categories = TextEditingController(text: 'Points, Bonus'),
        target = TextEditingController(text: '0'),
        seconds = TextEditingController(text: '150');
    bool low = false, coop = false;
    final form = GlobalKey<FormState>();
    try {
      final accepted = await showFormDialog<bool>(
        context: context,
        builder: (dialog) => StatefulBuilder(
          builder: (context, set) => AlertDialog(
            title: Text(
              tr(context, 'Votre modèle de jeu', 'Your game template'),
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Form(
                  key: form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: name,
                        maxLength: 80,
                        decoration: const InputDecoration(
                          labelText: 'Nom / Name',
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Nom requis' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: description,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLength: 500,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: categories,
                        decoration: InputDecoration(
                          labelText: tr(
                            context,
                            'Catégories séparées par des virgules',
                            'Comma-separated categories',
                          ),
                        ),
                        validator: (v) {
                          final list = v!
                              .split(',')
                              .map((s) => s.trim())
                              .toList();
                          return list.isEmpty ||
                                  list.length > 32 ||
                                  list.any((s) => s.isEmpty || s.length > 40) ||
                                  list.toSet().length != list.length
                              ? 'Catégories invalides'
                              : null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: target,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: tr(
                            context,
                            'Objectif de points (0 = libre)',
                            'Target score (0 = free)',
                          ),
                        ),
                        validator: (v) {
                          final n = double.tryParse(v ?? '');
                          return n == null || !n.isFinite || n < 0
                              ? 'Objectif invalide'
                              : null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: seconds,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: tr(
                            context,
                            'Temps par tour en secondes',
                            'Seconds per turn',
                          ),
                        ),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          return n == null || n < 1 || n > 86400
                              ? '1–86400'
                              : null;
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          tr(
                            context,
                            'Le moins de points gagne',
                            'Lowest score wins',
                          ),
                        ),
                        value: low,
                        onChanged: (v) => set(() => low = v),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          tr(
                            context,
                            'Objectif coopératif',
                            'Cooperative target',
                          ),
                        ),
                        value: coop,
                        onChanged: (v) => set(() => coop = v),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialog, false),
                child: Text(tr(context, 'Annuler', 'Cancel')),
              ),
              FilledButton(
                onPressed: () {
                  if (form.currentState!.validate()) {
                    Navigator.pop(dialog, true);
                  }
                },
                child: Text(tr(context, 'Enregistrer', 'Save')),
              ),
            ],
          ),
        ),
      );
      if (accepted == true) {
        await ref
            .read(workspaceProvider.notifier)
            .addTemplate(
              GameTemplate(
                id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
                name: name.text.trim(),
                description: description.text,
                categories: categories.text
                    .split(',')
                    .map((s) => s.trim())
                    .toList(),
                target: double.parse(target.text),
                seconds: int.parse(seconds.text),
                lowestWins: low,
                cooperative: coop,
              ),
            );
      }
    } finally {
      for (final c in [name, description, categories, target, seconds]) {
        c.dispose();
      }
    }
  }

  Future<void> importTemplate(BuildContext context, WidgetRef ref) async {
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
      await ref.read(workspaceProvider.notifier).addTemplate(template);
      if (context.mounted) {
        notify(context, tr(context, 'Modèle importé', 'Template imported'));
      }
    } catch (error) {
      if (context.mounted) notify(context, 'Import impossible : $error');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(workspaceProvider).requireValue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeckHeading(
          eyebrow: tr(
            context,
            'Vos règles / vos parties',
            'Your rules / your games',
          ),
          title: tr(context, 'Votre prochaine partie', 'Your next game'),
          subtitle: tr(
            context,
            'Ces modèles configurent réellement les scores, objectifs et minuteries.',
            'These templates configure scores, targets and timers.',
          ),
          action: FilledButton.icon(
            onPressed: () => create(context, ref),
            icon: const Icon(Icons.add),
            label: Text(tr(context, 'Créer un modèle', 'Create template')),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: OutlinedButton.icon(
            onPressed: () => importTemplate(context, ref),
            icon: const Icon(Icons.file_open_outlined),
            label: Text(
              tr(context, 'Importer un modèle JSON', 'Import JSON template'),
            ),
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
                      Icon(
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
                        t.name.toUpperCase(),
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
                        onPressed: () => showNewGame(context, ref, template: t),
                        child: Text(
                          tr(context, 'Jouer avec ce modèle', 'Use template'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
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
                                if (await confirm(
                                  context,
                                  tr(
                                    context,
                                    'Supprimer le modèle ?',
                                    'Delete template?',
                                  ),
                                  t.name,
                                )) {
                                  await ref
                                      .read(workspaceProvider.notifier)
                                      .saveWorkspace(
                                        ws.copyWith(
                                          templates: ws.templates
                                              .where((x) => x.id != t.id)
                                              .toList(),
                                        ),
                                      );
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
