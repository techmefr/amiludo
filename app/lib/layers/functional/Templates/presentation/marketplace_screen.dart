import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../technical/Theme/full_page.dart';
import '../../../technical/Theme/deck_widgets.dart';
import '../../../technical/About/app_info.dart';
import '../../Workspace/workspace_controller.dart';
import '../domain/game_template.dart';
import '../domain/pack_catalog.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  List<GameTemplate> packs = [];
  bool loading = true;
  String query = '', filter = 'Tous';
  String? error;
  bool online = false;
  @override
  void initState() {
    super.initState();
    loadLocal();
  }

  Future<void> loadLocal() async {
    try {
      final data = PackCatalog.decode(
        await rootBundle.loadString('assets/community/catalog.json'),
      );
      if (mounted) {
        setState(() {
          packs = data;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'Catalogue indisponible : $e';
        });
      }
    }
  }

  Future<void> refresh() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await PackCatalog.fetch();
      if (mounted) {
        setState(() {
          packs = data;
          online = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => error = 'Actualisation impossible. Les packs installés restent disponibles hors connexion.',
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> install(GameTemplate p) async {
    final existing = ref
        .read(workspaceProvider)
        .requireValue
        .templates
        .where((t) => t.id == p.id)
        .firstOrNull;
    if (!await confirm(
      context,
      existing == null ? 'Installer ce pack ?' : 'Remplacer le pack local ?',
      '${p.name} · ${p.revision}\n${p.author} · ${p.license}\n${existing == null ? "Le pack sera copié sur cet appareil." : "Les modifications locales de ce pack seront remplacées. Exportez-les pour les conserver."}',
    )) {
      return;
    }
    await ref.read(workspaceProvider.notifier).addTemplate(p);
    if (mounted) {
      notify(context, 'Pack installé. Retrouvez-le dans vos modèles.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ws = ref.watch(workspaceProvider).value;
    final shown = packs
        .where(
          (p) =>
              '${p.name} ${p.description} ${p.author}'.toLowerCase().contains(
                query.toLowerCase(),
              ) &&
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
                onPressed: loading ? null : refresh,
                icon: const Icon(Icons.refresh),
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
            online ? 'Catalogue public actualisé' : 'Catalogue fourni avec l’application. Actualisez pour découvrir les nouvelles contributions.',
          ),
          if (loading) const LinearProgressIndicator(),
          if (error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(error!),
            ),
          const SizedBox(height: 20),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Rechercher un jeu, un pack ou un auteur',
              prefixIcon: Icon(Icons.search),
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
          if (!loading && shown.isEmpty)
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
                          onPressed: ws == null ? null : () => install(p),
                          child: Text(
                            ws?.templates.any((t) => t.id == p.id) == true
                                ? 'Réinstaller / remplacer'
                                : 'Installer le pack',
                          ),
                        ),
                        if (ws?.templates.any((t) => t.id == p.id) == true)
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
