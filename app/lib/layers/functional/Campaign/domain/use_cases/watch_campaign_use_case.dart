import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_progress.dart';
import 'package:amiludo/layers/functional/Campaign/domain/gateways/campaign_gateway.dart';

class WatchCampaignUseCase {
  WatchCampaignUseCase(this._campaign);

  final CampaignGateway _campaign;

  Stream<CampaignProgress> call() => _campaign.changes;
}
