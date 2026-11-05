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
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
        ? context.l10n.templatesThePackWillBeCopied
        : context.l10n.templatesLocalChangesToThisPack;
    if (!await confirm(
      context,
      existing == null
          ? context.l10n.templatesInstallThisPack
          : context.l10n.templatesReplaceTheLocalPack,
      '${p.name} · ${p.revision}\n${p.author} · ${p.license}\n$detail',
    )) {
      return;
    }
    await templates.addTemplate(p);
    if (mounted) {
      notify(
        context,
        context.l10n.templatesPackInstalledFindItIn,
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
      title: context.l10n.templatesCommunityGallery,
      fallback: '/templates',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CatalogHeader(catalog: catalog),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              labelText: context.l10n.templatesSearchAGameAPack,
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
              context.l10n.templatesNoPackForThisSearch,
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
      PackFilter.all => context.l10n.templatesAll,
      PackFilter.dice => context.l10n.templatesDice,
      PackFilter.roles => context.l10n.templatesRoles,
      PackFilter.scores => context.l10n.templatesScores,
      PackFilter.characters => context.l10n.templatesCharacters,
    };

String _errorText(BuildContext context, MarketplaceError error) =>
    switch (error) {
      MarketplaceError.unavailable => context.l10n.templatesCatalogueUnavailable,
      MarketplaceError.refreshFailed => context.l10n.templatesCouldNotRefreshInstalledPacks,
    };

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader({required this.catalog});
  final MarketplaceState catalog;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DeckHeading(
        eyebrow: context.l10n.templatesCreateSharePlay,
        title: context.l10n.templatesToolsAreMadeToBe,
        subtitle: context.l10n.templatesInstallAPackCustomiseIt,
      ),
      _MarketplaceActions(loading: catalog.loading),
      const SizedBox(height: 16),
      Text(
        catalog.online
            ? context.l10n.templatesPublicCatalogueRefreshed
            : context.l10n.templatesCatalogueBundledWithTheApp,
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
            context.l10n.templatesRefreshTheGallery,
          ),
        ),
        OutlinedButton(
          onPressed: () => context.push('/builder/new'),
          child: Text(context.l10n.templatesCreateMyPack),
        ),
        TextButton(
          onPressed: () => openProjectLink(
            context,
            '$projectUrl/blob/main/community/README.md',
          ),
          child: Text(
            context.l10n.templatesHowToPublishMyPack,
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
              context.l10n.templatesDiceTypesRolesCategoriesBoosters(p.dice.length, p.roles.length, p.scoring.length, p.creation.length),
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
                  context.l10n.templatesReferenceRules,
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
                        ? context.l10n.templatesReinstallReplace
                        : context.l10n.templatesInstallThePack,
                  ),
                ),
                if (installed)
                  OutlinedButton(
                    onPressed: () => context.push('/pack/${p.id}'),
                    child: Text(context.l10n.templatesOpenMyPack),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
