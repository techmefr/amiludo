import 'package:amiludo/layers/functional/Campaign/domain/gateways/campaign_gateway.dart';

class LoadCampaignUseCase {
  LoadCampaignUseCase(this._campaign);

  final CampaignGateway _campaign;

  Future<void> call() => _campaign.load();
}
