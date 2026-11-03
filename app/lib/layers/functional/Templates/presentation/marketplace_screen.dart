import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/About/app_info.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/marketplace_cubit.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/marketplace_state.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/templates_cubit.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String query = '';
  PackFilter filter = PackFilter.all;

  Future<void> install(GameTemplate p) async {
    final templates = context.read<TemplatesCubit>();
    final existing = templates.state.templates
        .where((t) => t.id == p.id)
        .firstOrNull;
    final detail = existing == null
        ? tr(
            context,
            'Le pack sera copié sur cet appareil.',
            'The pack will be copied to this device.',
          )
        : tr(
            context,
            'Les modifications locales de ce pack seront remplacées. Exportez-les pour les conserver.',
            'Local changes to this pack will be replaced. Export them to keep them.',
          );
    if (!await confirm(
      context,
      existing == null
          ? tr(context, 'Installer ce pack ?', 'Install this pack?')
          : tr(context, 'Remplacer le pack local ?', 'Replace the local pack?'),
      '${p.name} · ${p.revision}\n${p.author} · ${p.license}\n$detail',
    )) {
      return;
    }
    await templates.addTemplate(p);
    if (mounted) {
      notify(
        context,
        tr(
          context,
          'Pack installé. Retrouvez-le dans vos modèles.',
          'Pack installed. Find it in your templates.',
        ),
      );
    }
  }

  List<GameTemplate> _shown(List<GameTemplate> packs) => packs
      .where(
        (p) =>
            '${p.name} ${p.englishName} ${p.description} ${p.author}'
                .toLowerCase()
                .contains(query.toLowerCase()) &&
            filter.matches(p),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final installed = context.watch<TemplatesCubit>().state.templates;
    final catalog = context.watch<MarketplaceCubit>().state;
    final shown = _shown(catalog.packs);
    return FullPage(
      title: tr(context, 'Galerie communautaire', 'Community gallery'),
      fallback: '/templates',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CatalogHeader(catalog: catalog),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              labelText: tr(
                context,
                'Rechercher un jeu, un pack ou un auteur',
                'Search a game, a pack or an author',
              ),
              prefixIcon: const Center(
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
              for (final f in PackFilter.values)
                ChoiceChip(
                  label: Text(_filterLabel(context, f)),
                  selected: filter == f,
                  onSelected: (_) => setState(() => filter = f),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (!catalog.loading && shown.isEmpty)
            Text(
              tr(
                context,
                'Aucun pack pour cette recherche.',
                'No pack for this search.',
              ),
            ),
          for (final p in shown)
            _PackCard(
              pack: p,
              installed: installed.any((t) => t.id == p.id),
              onInstall: () => install(p),
            ),
        ],
      ),
    );
  }
}

String _filterLabel(BuildContext context, PackFilter filter) =>
    switch (filter) {
      PackFilter.all => tr(context, 'Tous', 'All'),
      PackFilter.dice => tr(context, 'Dés', 'Dice'),
      PackFilter.roles => tr(context, 'Rôles', 'Roles'),
      PackFilter.scores => tr(context, 'Scores', 'Scores'),
      PackFilter.characters => tr(context, 'Personnages', 'Characters'),
    };

String _errorText(BuildContext context, MarketplaceError error) =>
    switch (error) {
      MarketplaceError.unavailable => tr(
        context,
        'Catalogue indisponible.',
        'Catalogue unavailable.',
      ),
      MarketplaceError.refreshFailed => tr(
        context,
        'Actualisation impossible. Les packs installés restent disponibles hors connexion.',
        'Could not refresh. Installed packs stay available offline.',
      ),
    };

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader({required this.catalog});
  final MarketplaceState catalog;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DeckHeading(
        eyebrow: tr(
          context,
          'CRÉER / PARTAGER / JOUER',
          'CREATE / SHARE / PLAY',
        ),
        title: tr(
          context,
          'Les outils se partagent',
          'Tools are made to be shared',
        ),
        subtitle: tr(
          context,
          'Installez un pack, personnalisez-le et jouez hors connexion. Le catalogue démarre avec des exemples originaux ; les contributions sont relues sur le dépôt public.',
          'Install a pack, customise it and play offline. The catalogue starts with original examples; contributions are reviewed on the public repository.',
        ),
      ),
      _MarketplaceActions(loading: catalog.loading),
      const SizedBox(height: 16),
      Text(
        catalog.online
            ? tr(
                context,
                'Catalogue public actualisé',
                'Public catalogue refreshed',
              )
            : tr(
                context,
                'Catalogue fourni avec l’application. Actualisez pour découvrir les nouvelles contributions.',
                'Catalogue bundled with the app. Refresh to discover new contributions.',
              ),
      ),
      if (catalog.loading) const LinearProgressIndicator(),
      if (catalog.error case final error?)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(_errorText(context, error)),
        ),
    ],
  );
}

class _MarketplaceActions extends StatelessWidget {
  const _MarketplaceActions({required this.loading});
  final bool loading;
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: loading ? null : context.read<MarketplaceCubit>().refresh,
          icon: const DeckIcon(Icons.refresh),
          label: Text(
            tr(context, 'Actualiser la galerie', 'Refresh the gallery'),
          ),
        ),
        OutlinedButton(
          onPressed: () => context.push('/builder/new'),
          child: Text(tr(context, 'Créer mon pack', 'Create my pack')),
        ),
        TextButton(
          onPressed: () => openProjectLink(
            context,
            '$projectUrl/blob/main/community/README.md',
          ),
          child: Text(
            tr(
              context,
              'Comment publier mon pack ?',
              'How to publish my pack?',
            ),
          ),
        ),
      ],
    );
  }
}

class _PackCard extends StatelessWidget {
  const _PackCard({
    required this.pack,
    required this.installed,
    required this.onInstall,
  });
  final GameTemplate pack;
  final bool installed;
  final VoidCallback onInstall;
  @override
  Widget build(BuildContext context) {
    final p = pack;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DeckPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(p.description),
            Text('${p.author} · ${p.revision} · ${p.license}'),
            const SizedBox(height: 12),
            Text(
              tr(
                context,
                '${p.dice.length} types de dés · ${p.roles.length} rôles · ${p.scoring.length} catégories · ${p.creation.length} boosters',
                '${p.dice.length} dice types · ${p.roles.length} roles · ${p.scoring.length} categories · ${p.creation.length} boosters',
              ),
            ),
            if (p.rulesNotes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(p.rulesNotes),
              ),
            if (p.rulesUrl.isNotEmpty)
              TextButton(
                onPressed: () => openProjectLink(context, p.rulesUrl),
                child: Text(
                  tr(context, 'Règles de référence', 'Reference rules'),
                ),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: onInstall,
                  child: Text(
                    installed
                        ? tr(
                            context,
                            'Réinstaller / remplacer',
                            'Reinstall / replace',
                          )
                        : tr(context, 'Installer le pack', 'Install the pack'),
                  ),
                ),
                if (installed)
                  OutlinedButton(
                    onPressed: () => context.push('/pack/${p.id}'),
                    child: Text(tr(context, 'Ouvrir mon pack', 'Open my pack')),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
