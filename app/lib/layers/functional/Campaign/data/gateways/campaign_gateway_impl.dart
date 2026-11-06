import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_progress.dart';
import 'package:amiludo/layers/functional/Campaign/domain/gateways/campaign_gateway.dart';
import 'package:amiludo/layers/technical/Storage/stored_document.dart';

class CampaignGatewayImpl extends StoredDocument<CampaignProgress>
    implements CampaignGateway {
  CampaignGatewayImpl(super.store)
    : super(
        id: 'campaign',
        empty: const CampaignProgress(),
        fromJson: CampaignProgress.fromJson,
        toJson: (progress) => progress.toJson(),
      );
}
