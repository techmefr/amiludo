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
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
        title: context.l10n.templatesPackNotFound,
        fallback: '/templates',
        child: Text(
          context.l10n.templatesThisPackIsNotInstalled,
        ),
      );
    }
    return FullPage(
      title: context.l10n.templatesPackSheet,
      fallback: '/templates',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (snapshot)
            Text(
              context.l10n.templatesRulesCopyKeptForThis,
            ),
          DeckHeading(
            eyebrow: 'PACK / ${p.revision}',
            title: p.name,
            subtitle: p.description,
          ),
          Text(
            '${p.author.isEmpty ? context.l10n.templatesUnknownAuthor : p.author} · ${p.license}',
          ),
          if (p.edition.isNotEmpty) Text(p.edition),
          const SizedBox(height: 24),
          if (p.englishName.isNotEmpty && p.englishName != p.name)
            Text(p.englishName),
          _PackPlayActions(pack: p, snapshot: snapshot),
          _PackRules(pack: p),
          SectionHeading(context.l10n.templatesShare),
          Text(
            context.l10n.templatesTheFileHoldsThePack,
          ),
          const SizedBox(height: 16),
          _PackShareActions(pack: p),
          const SizedBox(height: 12),
          Text(
            context.l10n.templatesToSubmitYourCreationExport,
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
      SectionHeading(context.l10n.templatesScoring),
      for (final rule in pack.scoring)
        Text('${rule.name} · ${rule.explanation}'),
      if (pack.scoring.isEmpty) Text(pack.categories.join(' · ')),
      SectionHeading(context.l10n.templatesRulesAndVariants),
      if (pack.rulesUrl.isNotEmpty)
        OutlinedButton.icon(
          onPressed: () => openProjectLink(context, pack.rulesUrl),
          icon: const DeckIcon(Icons.open_in_new),
          label: Text(
            context.l10n.templatesOpenTheReferenceRules,
          ),
        ),
      const SizedBox(height: 16),
      SelectableText(
        pack.rulesNotes.isEmpty
            ? context.l10n.templatesNoNotesYetYouCan
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
          child: Text(context.l10n.templatesPlayWithThisPack),
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
                  ? context.l10n.templatesCreateACharacter
                  : t.title,
            ),
          ),
        OutlinedButton(
          onPressed: () => context.push('/builder/${p.id}'),
          child: Text(context.l10n.templatesCustomise),
        ),
        TextButton(
          onPressed: () => context.go('/tools'),
          child: Text(
            context.l10n.templatesAllToolsInFreeMode,
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
            context.l10n.templatesExportThePackJson,
          ),
        ),
        OutlinedButton(
          onPressed: () => openProjectLink(
            context,
            '$projectUrl/upload/main/community/packs',
          ),
          child: Text(
            context.l10n.templatesSubmitToTheGallery,
          ),
        ),
      ],
    );
  }
}
