import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/atlas_tab.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/campaign_theme.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/cubit/notebook_cubit.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/entries_tab.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/journal_tab.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/oracle_panel.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/paper_look.dart';
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

class _CampaignView extends StatelessWidget {
  const _CampaignView({required this.campaign});
  final NotebookCampaign campaign;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cubit = context.read<NotebookCubit>();
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/notebook'),
          ),
          title: Text(campaign.title, overflow: TextOverflow.ellipsis),
          actions: [
            RibbonBookmark(color: Color(campaign.palette ?? 0xFFA3342B)),
            IconButton(
              tooltip: l.notebookFavorite,
              onPressed: () => cubit.toggleFavorite(campaign.id),
              icon: Icon(campaign.favorite ? Icons.star : Icons.star_border),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l.notebookTabJournal),
              Tab(text: l.notebookTabEntries),
              Tab(text: l.notebookTabOracle),
              Tab(text: l.notebookTabAtlas),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            JournalTab(campaign: campaign),
            EntriesTab(campaign: campaign),
            SingleChildScrollView(
              padding: const EdgeInsets.all(Space.lg),
              child: OraclePanel(
                chaos: campaign.chaos,
                onChaos: (v) =>
                    cubit.update(campaign.id, (c) => c.copyWith(chaos: v)),
                onPush: (kind, text) => cubit.addLine(campaign.id, kind, text),
              ),
            ),
            AtlasTab(campaign: campaign),
          ],
        ),
      ),
    );
  }
}
