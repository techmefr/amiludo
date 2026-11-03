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
      return FullPage(
        title: tr(context, 'Pack introuvable', 'Pack not found'),
        fallback: '/templates',
        child: Text(
          tr(
            context,
            'Ce pack n’est pas installé sur cet appareil.',
            'This pack is not installed on this device.',
          ),
        ),
      );
    }
    return FullPage(
      title: tr(context, 'Fiche du pack', 'Pack sheet'),
      fallback: '/templates',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (snapshot)
            Text(
              tr(
                context,
                'Copie des règles conservée pour cette partie.',
                'Rules copy kept for this game.',
              ),
            ),
          DeckHeading(
            eyebrow: 'PACK / ${p.revision}',
            title: p.name,
            subtitle: p.description,
          ),
          Text(
            '${p.author.isEmpty ? tr(context, 'Auteur non renseigné', 'Unknown author') : p.author} · ${p.license}',
          ),
          if (p.edition.isNotEmpty) Text(p.edition),
          const SizedBox(height: 24),
          if (p.englishName.isNotEmpty && p.englishName != p.name)
            Text(p.englishName),
          _PackPlayActions(pack: p, snapshot: snapshot),
          _PackRules(pack: p),
          SectionHeading(tr(context, 'Partager', 'Share')),
          Text(
            tr(
              context,
              'Le fichier contient les dés, rôles, décomptes et notes du pack. Il ne contient pas vos parties.',
              'The file holds the pack dice, roles, scoring and notes. It does not hold your games.',
            ),
          ),
          const SizedBox(height: 16),
          _PackShareActions(pack: p),
          const SizedBox(height: 12),
          Text(
            tr(
              context,
              'Pour proposer votre création : exportez le JSON, ouvrez GitHub, ajoutez le fichier et proposez une pull request. La publication suit une relecture. Un compte GitHub est nécessaire pour contribuer au catalogue.',
              'To submit your creation: export the JSON, open GitHub, add the file and open a pull request. Publication follows a review. A GitHub account is needed to contribute to the catalogue.',
            ),
          ),
        ],
      ),
    );
  }
}

class _PackRules extends StatelessWidget {
  const _PackRules({required this.pack});

  final GameTemplate pack;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionHeading(tr(context, 'Décompte', 'Scoring')),
      for (final rule in pack.scoring)
        Text('${rule.name} · ${rule.explanation}'),
      if (pack.scoring.isEmpty) Text(pack.categories.join(' · ')),
      SectionHeading(tr(context, 'Règles et variantes', 'Rules and variants')),
      if (pack.rulesUrl.isNotEmpty)
        OutlinedButton.icon(
          onPressed: () => openProjectLink(context, pack.rulesUrl),
          icon: const DeckIcon(Icons.open_in_new),
          label: Text(
            tr(
              context,
              'Ouvrir les règles de référence',
              'Open the reference rules',
            ),
          ),
        ),
      const SizedBox(height: 16),
      SelectableText(
        pack.rulesNotes.isEmpty
            ? tr(
                context,
                'Aucune consigne ajoutée. Vous pouvez écrire vos variantes dans le builder.',
                'No notes yet. You can write your variants in the builder.',
              )
            : pack.rulesNotes,
      ),
    ],
  );
}

class _PackPlayActions extends StatelessWidget {
  const _PackPlayActions({required this.pack, required this.snapshot});
  final GameTemplate pack;
  final bool snapshot;
  @override
  Widget build(BuildContext context) {
    final p = pack;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton(
          onPressed: () => context.push(
            GameSetupRequest.path,
            extra: GameSetupRequest(template: p),
          ),
          child: Text(tr(context, 'Jouer avec ce pack', 'Play with this pack')),
        ),
        for (final t in toolDefinitions.where(
          (t) => p.modules.contains(t.id) && t.id != 'scores',
        ))
          OutlinedButton(
            onPressed: () => context.push(
              '/tools/${t.id}?pack=${p.id}${snapshot ? '&session=1' : ''}',
            ),
            child: Text(
              t.id == 'character'
                  ? tr(context, 'Créer un personnage', 'Create a character')
                  : t.title,
            ),
          ),
        OutlinedButton(
          onPressed: () => context.push('/builder/${p.id}'),
          child: Text(tr(context, 'Personnaliser', 'Customise')),
        ),
        TextButton(
          onPressed: () => context.go('/tools'),
          child: Text(
            tr(
              context,
              'Tous les outils en mode libre',
              'All tools in free mode',
            ),
          ),
        ),
      ],
    );
  }
}

class _PackShareActions extends StatelessWidget {
  const _PackShareActions({required this.pack});
  final GameTemplate pack;
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: () => FileTransfer.shareText(
            jsonEncode({
              'format': 'table-companion-template',
              'version': 1,
              'template': pack.toJson(),
            }),
            'pack-${pack.id}.json',
          ),
          icon: const DeckIcon(Icons.file_download_outlined),
          label: Text(
            tr(context, 'Exporter le pack JSON', 'Export the pack JSON'),
          ),
        ),
        OutlinedButton(
          onPressed: () => openProjectLink(
            context,
            '$projectUrl/upload/main/community/packs',
          ),
          child: Text(
            tr(context, 'Proposer à la galerie', 'Submit to the gallery'),
          ),
        ),
      ],
    );
  }
}
