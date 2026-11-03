import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/technical/About/app_info.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/templates_cubit.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/game_setup_request.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/tool_catalog.dart';

class PackDetail extends StatelessWidget {
  const PackDetail({super.key, required this.id, this.snapshot = false});
  final String id;
  final bool snapshot;
  @override
  Widget build(BuildContext context) {
    final ws = context.watch<TemplatesCubit>().state;
    final p = [
      if (snapshot && ws.current?.pack != null) ws.current!.pack!,
      ...ws.templates,
      ...GameTemplate.builtIn,
      if (ws.current?.pack != null) ws.current!.pack!,
    ].where((t) => t.id == id).firstOrNull;
    if (p == null) {
      return const FullPage(
        title: 'Pack introuvable',
        fallback: '/templates',
        child: Text('Ce pack n’est pas installé sur cet appareil.'),
      );
    }
    return FullPage(
      title: tr(context, 'Fiche du pack', 'Pack sheet'),
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
          if (p.englishName.isNotEmpty && p.englishName != p.name)
            Text(p.englishName),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: () => context.push(
                  GameSetupRequest.path,
                  extra: GameSetupRequest(template: p),
                ),
                child: const Text('Jouer avec ce pack'),
              ),
              for (final t in toolDefinitions.where(
                (t) => p.modules.contains(t.id) && t.id != 'scores',
              ))
                OutlinedButton(
                  onPressed: () => context.push(
                    '/tools/${t.id}?pack=${p.id}${snapshot ? '&session=1' : ''}',
                  ),
                  child: Text(
                    t.id == 'character' ? 'Créer un personnage' : t.title,
                  ),
                ),
              OutlinedButton(
                onPressed: () => context.push('/builder/${p.id}'),
                child: const Text('Personnaliser'),
              ),
              TextButton(
                onPressed: () => context.go('/tools'),
                child: const Text('Tous les outils en mode libre'),
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
