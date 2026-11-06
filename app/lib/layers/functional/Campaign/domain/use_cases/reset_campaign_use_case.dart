import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_progress.dart';
import 'package:amiludo/layers/functional/Campaign/domain/gateways/campaign_gateway.dart';

class ResetCampaignUseCase {
  ResetCampaignUseCase(this._campaign);

  final CampaignGateway _campaign;

  Future<void> call() => _campaign.save(const CampaignProgress());
}
