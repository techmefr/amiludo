import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_search.dart';

class CampaignHit {
  const CampaignHit(this.campaign, this.hit);
  final NotebookCampaign campaign;
  final SearchHit hit;
}

List<CampaignHit> searchNotebook(Notebook notebook, String query) => [
  for (final campaign in notebook.sorted)
    for (final hit in searchCampaign(campaign, query))
      CampaignHit(campaign, hit),
];
