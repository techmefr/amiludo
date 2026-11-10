import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/atlas_tab.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/campaign_theme.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/cubit/notebook_cubit.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/entries_tab.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/journal_tab.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/oracle_panel.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/paper_look.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_bar_scope.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) => CampaignScope(
    id: id,
    builder: (context, campaign) => _CampaignView(campaign: campaign),
  );
}

class _CampaignView extends StatefulWidget {
  const _CampaignView({required this.campaign});
  final NotebookCampaign campaign;

  @override
  State<_CampaignView> createState() => _CampaignViewState();
}

class _CampaignViewState extends State<_CampaignView> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cubit = context.read<NotebookCubit>();
    final campaign = widget.campaign;
    return FullPage(
      title: campaign.title,
      immersive: true,
      scroll: false,
      fallback: '/notebook',
      actions: [
        RibbonBookmark(color: Color(campaign.palette ?? 0xFFA3342B)),
        IconButton(
          tooltip: l.notebookFavorite,
          onPressed: () => cubit.toggleFavorite(campaign.id),
          icon: Icon(campaign.favorite ? Icons.star : Icons.star_border),
        ),
      ],
      tabs: ToolTabs(
        label: campaign.title,
        current: tab,
        onSelect: (i) => setState(() => tab = i),
        items: [
          ToolTab(id: 'journal', label: l.notebookTabJournal),
          ToolTab(id: 'entries', label: l.notebookTabEntries),
          ToolTab(id: 'oracle', label: l.notebookTabOracle),
          ToolTab(id: 'atlas', label: l.notebookTabAtlas),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: switch (tab) {
          0 => JournalTab(campaign: campaign),
          1 => EntriesTab(campaign: campaign),
          2 => SingleChildScrollView(
            padding: const EdgeInsets.all(Space.lg),
            child: OraclePanel(
              chaos: campaign.chaos,
              onChaos: (v) =>
                  cubit.update(campaign.id, (c) => c.copyWith(chaos: v)),
              onPush: (kind, text) => cubit.addLine(campaign.id, kind, text),
            ),
          ),
          _ => AtlasTab(campaign: campaign),
        },
      ),
    );
  }
}
