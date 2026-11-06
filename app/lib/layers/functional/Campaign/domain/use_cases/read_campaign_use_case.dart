import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_progress.dart';
import 'package:amiludo/layers/functional/Campaign/domain/gateways/campaign_gateway.dart';

class ReadCampaignUseCase {
  ReadCampaignUseCase(this._campaign);

  final CampaignGateway _campaign;

  CampaignProgress call() => _campaign.current;
}
