import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:amiludo/dice_sharing.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/functional/Templates/presentation/companion_file_actions.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/templates_cubit.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/game_setup_request.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';

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
      if (!context.mounted) return;
      final accepted = await acceptDice(context, text);
      final data = Map<String, dynamic>.from(jsonDecode(accepted) as Map);
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
        notify(context, context.l10n.templatesTemplateImported);
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
          eyebrow: context.l10n.templatesYourRulesYourGames,
          title: context.l10n.templatesYourGameCompanions,
          subtitle: context.l10n.templatesTheseTemplatesConfigureScoresTargets,
          action: FilledButton.icon(
            onPressed: () => create(context),
            icon: const DeckIcon(Icons.add),
            label: Text(context.l10n.templatesCreateCompanion),
          ),
        ),
        _TemplatesToolbar(onImport: () => importTemplate(context)),
        ResponsiveGrid(
          minimumWidth: 250,
          children: [...GameTemplate.builtIn, ...ws.templates]
              .map(
                (t) => _TemplateCard(
                  template: t,
                  custom: ws.templates.any((v) => v.id == t.id),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _TemplatesToolbar extends StatelessWidget {
  const _TemplatesToolbar({required this.onImport});
  final VoidCallback onImport;
  @override
  Widget build(BuildContext context) {
    return Padding(
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
            onPressed: () => importCompanionFile(context),
            icon: const DeckIcon(Icons.download_outlined),
            label: Text(context.l10n.templatesImportCompanion),
          ),
          OutlinedButton.icon(
            onPressed: onImport,
            icon: const DeckIcon(Icons.file_open_outlined),
            label: Text(context.l10n.templatesImportJsonTemplate),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template, required this.custom});
  final GameTemplate template;
  final bool custom;
  @override
  Widget build(BuildContext context) {
    final t = template, theme = Theme.of(context);
    return DeckPanel(
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
            color: theme.colorScheme.accentInk,
          ),
          const SizedBox(height: 20),
          Text(t.name, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(t.description),
          const SizedBox(height: 16),
          Text(
            [
              t.categories.join(' / '),
              '${t.seconds}s',
              if (t.target > 0) context.l10n.templatesTarget(t.target),
            ].join(' · '),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.push(
                GameSetupRequest.path,
                extra: GameSetupRequest(template: t),
              ),
              child: Text(context.l10n.templatesUseTemplate),
            ),
          ),
          const SizedBox(height: 8),
          _TemplateActions(template: t, custom: custom),
        ],
      ),
    );
  }
}

class _TemplateActions extends StatelessWidget {
  const _TemplateActions({required this.template, required this.custom});
  final GameTemplate template;
  final bool custom;

  Future<void> _remove(BuildContext context) async {
    final templates = context.read<TemplatesCubit>();
    if (await confirm(
      context,
      context.l10n.templatesDeleteTemplate,
      template.name,
    )) {
      await templates.removeTemplate(template.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = template;
    return Wrap(
      children: [
        IconButton(
          tooltip: custom
              ? context.l10n.templatesEdit
              : context.l10n.templatesCopyToMyWorkshop,
          onPressed: () => context.push('/builder/${t.id}'),
          icon: DeckIcon(
            custom ? Icons.edit_outlined : Icons.copy_outlined,
            size: 20,
          ),
        ),
        IconButton(
          tooltip: context.l10n.templatesPackToolsAndRules,
          onPressed: () => context.push('/pack/${t.id}'),
          icon: const DeckIcon(Icons.menu_book_outlined, size: 20),
        ),
        IconButton(
          tooltip: context.l10n.templatesShare,
          icon: const DeckIcon(Icons.share_outlined, size: 20),
          onPressed: () async => FileTransfer.shareText(
            await embedDice(
              jsonEncode({
                'format': 'table-companion-template',
                'version': 1,
                'template': t.toJson(),
              }),
            ),
            'modele-${t.id}.json',
          ),
        ),
        IconButton(
          tooltip: context.l10n.templatesShareCompanion,
          icon: const DeckIcon(Icons.ios_share, size: 20),
          onPressed: () => shareCompanionFile(t),
        ),
        if (custom) ...[
          IconButton(
            tooltip: context.l10n.templatesShareByQr,
            icon: const DeckIcon(Icons.qr_code_2, size: 20),
            onPressed: () => context.push('/share?pack=${t.id}'),
          ),
          IconButton(
            tooltip: context.l10n.randomDelete,
            icon: const DeckIcon(Icons.delete_outline, size: 20),
            onPressed: () => _remove(context),
          ),
        ],
      ],
    );
  }
}
