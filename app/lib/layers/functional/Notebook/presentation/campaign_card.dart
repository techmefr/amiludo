import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/campaign_theme.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/notebook_images.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

enum CampaignAction { look, export, delete }

class CampaignCard extends StatelessWidget {
  const CampaignCard({
    super.key,
    required this.campaign,
    required this.onOpen,
    required this.onFavorite,
    required this.onAction,
  });

  final NotebookCampaign campaign;
  final VoidCallback onOpen, onFavorite;
  final ValueChanged<CampaignAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = campaignTheme(Theme.of(context), campaign);
    final scheme = theme.colorScheme;
    final header = campaign.headerImageId;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: scheme.surfaceContainerHigh,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: Space.section + Space.xl,
              width: double.infinity,
              color: scheme.primaryContainer,
              child: header == null
                  ? null
                  : NotebookImage(id: header, height: Space.section + Space.xl),
            ),
            Padding(
              padding: const EdgeInsets.all(Space.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          campaign.kind == CampaignKind.solo
                              ? l.notebookKindSolo
                              : l.notebookKindGm,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l.notebookFavorite,
                    constraints: const BoxConstraints(
                      minWidth: Targets.minimum,
                      minHeight: Targets.minimum,
                    ),
                    onPressed: onFavorite,
                    icon: Icon(
                      campaign.favorite ? Icons.star : Icons.star_border,
                    ),
                  ),
                  PopupMenuButton<CampaignAction>(
                    onSelected: onAction,
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: CampaignAction.look,
                        child: Text(l.notebookLook),
                      ),
                      PopupMenuItem(
                        value: CampaignAction.export,
                        child: Text(l.notebookExport),
                      ),
                      PopupMenuItem(
                        value: CampaignAction.delete,
                        child: Text(l.notebookDelete),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
