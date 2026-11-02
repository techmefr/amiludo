import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../technical/Theme/full_page.dart';
import '../../../technical/Theme/deck_widgets.dart';
import '../../../technical/Files/file_transfer.dart';
import '../../../technical/About/app_info.dart';
import '../../Workspace/workspace_controller.dart';
import '../../Workspace/presentation/game_setup.dart';
import '../domain/game_template.dart';

class PackDetail extends ConsumerWidget {
  const PackDetail({super.key, required this.id, this.snapshot = false});
  final String id;
  final bool snapshot;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(workspaceProvider).value;
    final p = [
      if (snapshot && ws?.current?.pack != null) ws!.current!.pack!,
      ...?ws?.templates,
      ...GameTemplate.builtIn,
      if (ws?.current?.pack != null) ws!.current!.pack!,
    ].where((t) => t.id == id).firstOrNull;
    if (p == null) {
      return const FullPage(
        title: 'Pack introuvable',
        fallback: '/templates',
        child: Text('Ce pack n’est pas installé sur cet appareil.'),
      );
    }
    return FullPage(
      title: p.name,
      fallback: '/templates',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (snapshot)
            const Text('Copie des règles conservée pour cette partie.'),
          DeckHeading(
            eyebrow: 'PACK / ${p.revision}',
            title: p.name,
            subtitle: p.description,
          ),
          Text(
            '${p.author.isEmpty ? 'Auteur non renseigné' : p.author} · ${p.license}',
          ),
          if (p.edition.isNotEmpty) Text(p.edition),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: () => showNewGame(context, ref, template: p),
                child: const Text('Jouer avec ce pack'),
              ),
              if (p.creation.isNotEmpty)
                OutlinedButton(
                  onPressed: () => context.push(
                    '/tools/character?pack=${p.id}${snapshot ? '&session=1' : ''}',
                  ),
                  child: const Text('Créer un personnage'),
                ),
              if (p.dice.isNotEmpty)
                OutlinedButton(
                  onPressed: () => context.push(
                    '/tools/dice?pack=${p.id}${snapshot ? '&session=1' : ''}',
                  ),
                  child: const Text('Dés du jeu'),
                ),
              if (p.roles.isNotEmpty)
                OutlinedButton(
                  onPressed: () => context.push(
                    '/tools/roles?pack=${p.id}${snapshot ? '&session=1' : ''}',
                  ),
                  child: const Text('Rôles du jeu'),
                ),
              OutlinedButton(
                onPressed: () => context.push('/builder/${p.id}'),
                child: const Text('Personnaliser'),
              ),
            ],
          ),
          const SectionHeading('Décompte'),
          for (final rule in p.scoring)
            Text('${rule.name} · ${rule.explanation}'),
          if (p.scoring.isEmpty) Text(p.categories.join(' · ')),
          const SectionHeading('Règles et variantes'),
          if (p.rulesUrl.isNotEmpty)
            OutlinedButton.icon(
              onPressed: () => openProjectLink(context, p.rulesUrl),
              icon: const DeckIcon(Icons.open_in_new),
              label: const Text('Ouvrir les règles de référence'),
            ),
          const SizedBox(height: 16),
          SelectableText(
            p.rulesNotes.isEmpty
                ? 'Aucune consigne ajoutée. Vous pouvez écrire vos variantes dans le builder.'
                : p.rulesNotes,
          ),
          const SectionHeading('Partager'),
          const Text(
            'Le fichier contient les dés, rôles, décomptes et notes du pack. Il ne contient pas vos parties.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () => FileTransfer.shareText(
                  jsonEncode({
                    'format': 'table-companion-template',
                    'version': 1,
                    'template': p.toJson(),
                  }),
                  'pack-${p.id}.json',
                ),
                icon: const DeckIcon(Icons.file_download_outlined),
                label: const Text('Exporter le pack JSON'),
              ),
              OutlinedButton(
                onPressed: () => openProjectLink(
                  context,
                  '$projectUrl/upload/main/community/packs',
                ),
                child: const Text('Proposer à la galerie'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Pour proposer votre création : exportez le JSON, ouvrez GitHub, ajoutez le fichier et proposez une pull request. La publication suit une relecture. Un compte GitHub est nécessaire pour contribuer au catalogue.',
          ),
        ],
      ),
    );
  }
}
