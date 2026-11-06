import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_catalog.dart';
import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_progress.dart';
import 'package:amiludo/layers/functional/Campaign/domain/use_cases/complete_mission_use_case.dart';
import 'package:amiludo/layers/functional/Campaign/domain/use_cases/load_campaign_use_case.dart';
import 'package:amiludo/layers/functional/Campaign/domain/use_cases/read_campaign_use_case.dart';
import 'package:amiludo/layers/functional/Campaign/domain/use_cases/reset_campaign_use_case.dart';
import 'package:amiludo/layers/functional/Campaign/domain/use_cases/watch_campaign_use_case.dart';

class CampaignCubit extends Cubit<CampaignProgress> {
  CampaignCubit(
    ReadCampaignUseCase readCampaign,
    WatchCampaignUseCase watchCampaign,
    this._completeMission,
    this._resetCampaign,
    LoadCampaignUseCase loadCampaign,
  ) : super(readCampaign()) {
    loadCampaign();
    _subscription = watchCampaign().listen(emit);
  }

  final CompleteMissionUseCase _completeMission;
  final ResetCampaignUseCase _resetCampaign;
  late final StreamSubscription<CampaignProgress> _subscription;

  Future<void> complete(Mission mission, {int? choice}) =>
      _completeMission(mission, choice: choice);

  Future<void> reset() => _resetCampaign();

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
