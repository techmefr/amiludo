import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_progress.dart';

abstract class CampaignGateway {
  CampaignProgress get current;
  Stream<CampaignProgress> get changes;
  Future<void> save(CampaignProgress progress);
}
