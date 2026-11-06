import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_catalog.dart';
import 'package:amiludo/layers/functional/Campaign/domain/gateways/campaign_gateway.dart';

class CompleteMissionUseCase {
  CompleteMissionUseCase(this._campaign);

  final CampaignGateway _campaign;

  Future<void> call(Mission mission, {int? choice}) {
    final progress = _campaign.current;
    if (!progress.isUnlocked(mission)) return Future.value();
    return _campaign.save(progress.withCompleted(mission.id, choice: choice));
  }
}
