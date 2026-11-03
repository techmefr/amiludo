import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/About/app_info.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/marketplace_cubit.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/templates_cubit.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String query = '', filter = 'Tous';

  Future<void> install(GameTemplate p) async {
    final templates = context.read<TemplatesCubit>();
    final existing = templates.state.templates
        .where((t) => t.id == p.id)
        .firstOrNull;
    if (!await confirm(
      context,
      existing == null ? 'Installer ce pack ?' : 'Remplacer le pack local ?',
      '${p.name} · ${p.revision}\n${p.author} · ${p.license}\n${existing == null ? "Le pack sera copié sur cet appareil." : "Les modifications locales de ce pack seront remplacées. Exportez-les pour les conserver."}',
    )) {
      return;
    }
    await templates.addTemplate(p);
    if (mounted) {
      notify(context, 'Pack installé. Retrouvez-le dans vos modèles.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final installed = context.watch<TemplatesCubit>().state.templates;
    final catalog = context.watch<MarketplaceCubit>().state;
    final shown = catalog.packs
        .where(
          (p) =>
              '${p.name} ${p.englishName} ${p.description} ${p.author}'
                  .toLowerCase()
                  .contains(query.toLowerCase()) &&
              (filter == 'Tous' ||
                  filter == 'Dés' && p.dice.isNotEmpty ||
                  filter == 'Rôles' && p.roles.isNotEmpty ||
                  filter == 'Scores' && p.scoring.isNotEmpty ||
                  filter == 'Personnages' && p.creation.isNotEmpty),
        )
        .toList();
    return FullPage(
      title: 'Galerie communautaire',
      fallback: '/templates',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DeckHeading(
            eyebrow: 'CRÉER / PARTAGER / JOUER',
            title: 'Les outils se partagent',
            subtitle: 'Installez un pack, personnalisez-le et jouez hors connexion. Le catalogue démarre avec des exemples originaux ; les contributions sont relues sur le dépôt public.',
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: catalog.loading
                    ? null
                    : context.read<MarketplaceCubit>().refresh,
                icon: const DeckIcon(Icons.refresh),
                label: const Text('Actualiser la galerie'),
              ),
              OutlinedButton(
                onPressed: () => context.push('/builder/new'),
                child: const Text('Créer mon pack'),
              ),
              TextButton(
                onPressed: () => openProjectLink(
                  context,
                  '$projectUrl/blob/main/community/README.md',
                ),
                child: const Text('Comment publier mon pack ?'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            catalog.online ? 'Catalogue public actualisé' : 'Catalogue fourni avec l’application. Actualisez pour découvrir les nouvelles contributions.',
          ),
          if (catalog.loading) const LinearProgressIndicator(),
          if (catalog.error case final error?)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(error),
            ),
          const SizedBox(height: 20),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Rechercher un jeu, un pack ou un auteur',
              prefixIcon: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: DeckIcon(Icons.search, size: 20),
              ),
            ),
            onChanged: (v) => setState(() => query = v),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              for (final f in ['Tous', 'Dés', 'Rôles', 'Scores', 'Personnages'])
                ChoiceChip(
                  label: Text(f),
                  selected: filter == f,
                  onSelected: (_) => setState(() => filter = f),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (!catalog.loading && shown.isEmpty)
            const Text('Aucun pack pour cette recherche.'),
          for (final p in shown)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: DeckPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(p.description),
                    Text('${p.author} · ${p.revision} · ${p.license}'),
                    const SizedBox(height: 12),
                    Text(
                      '${p.dice.length} types de dés · ${p.roles.length} rôles · ${p.scoring.length} catégories · ${p.creation.length} boosters',
                    ),
                    if (p.rulesNotes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(p.rulesNotes),
                      ),
                    if (p.rulesUrl.isNotEmpty)
                      TextButton(
                        onPressed: () => openProjectLink(context, p.rulesUrl),
                        child: const Text('Règles de référence'),
                      ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        FilledButton(
                          onPressed: () => install(p),
                          child: Text(
                            installed.any((t) => t.id == p.id)
                                ? 'Réinstaller / remplacer'
                                : 'Installer le pack',
                          ),
                        ),
                        if (installed.any((t) => t.id == p.id))
                          OutlinedButton(
                            onPressed: () => context.push('/pack/${p.id}'),
                            child: const Text('Ouvrir mon pack'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
