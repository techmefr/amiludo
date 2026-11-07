import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Campaign/data/gateways/campaign_gateway_impl.dart';
import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_catalog.dart';
import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_progress.dart';
import 'package:amiludo/layers/functional/Campaign/domain/gateways/campaign_gateway.dart';
import 'package:amiludo/layers/functional/Campaign/domain/use_cases/complete_mission_use_case.dart';
import 'package:amiludo/layers/functional/Campaign/domain/use_cases/load_campaign_use_case.dart';
import 'package:amiludo/layers/functional/Campaign/domain/use_cases/read_campaign_use_case.dart';
import 'package:amiludo/layers/functional/Campaign/domain/use_cases/reset_campaign_use_case.dart';
import 'package:amiludo/layers/functional/Campaign/domain/use_cases/watch_campaign_use_case.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/cubit/campaign_cubit.dart';
import 'package:amiludo/layers/technical/Storage/document_store.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

class MemoryCampaign implements CampaignGateway {
  @override
  CampaignProgress current = const CampaignProgress();

  final _changes = StreamController<CampaignProgress>.broadcast(sync: true);

  @override
  Stream<CampaignProgress> get changes => _changes.stream;

  @override
  Future<void> load() async {}

  @override
  Future<void> save(CampaignProgress progress) async {
    current = progress;
    _changes.add(progress);
  }
}

CampaignCubit cubitOn(MemoryCampaign gateway) => CampaignCubit(
  ReadCampaignUseCase(gateway),
  WatchCampaignUseCase(gateway),
  CompleteMissionUseCase(gateway),
  ResetCampaignUseCase(gateway),
  LoadCampaignUseCase(gateway),
);

void main() {
  test('the campaign has five to six short missions with unique ids', () {
    expect(campaignMissions.length, inInclusiveRange(5, 6));
    expect(
      campaignMissions.map((m) => m.id).toSet().length,
      campaignMissions.length,
    );
    for (final mission in campaignMissions) {
      expect(mission.minutes, inInclusiveRange(3, 5));
    }
    expect(campaignUniverse, isNotEmpty);
  });

  test('missions unlock one after the other', () {
    var progress = const CampaignProgress();
    expect(progress.isUnlocked(campaignMissions[0]), isTrue);
    expect(progress.isUnlocked(campaignMissions[1]), isFalse);
    progress = progress.withCompleted(campaignMissions[0].id);
    expect(progress.isUnlocked(campaignMissions[1]), isTrue);
    expect(progress.next, campaignMissions[1]);
    expect(progress.finished, isFalse);
  });

  test('completing twice counts once and finishing all ends the campaign', () {
    var progress = const CampaignProgress();
    for (final mission in campaignMissions) {
      progress = progress.withCompleted(mission.id).withCompleted(mission.id);
    }
    expect(progress.doneCount, campaignMissions.length);
    expect(progress.finished, isTrue);
    expect(progress.next, isNull);
  });

  test('progress survives a json round trip and drops unknown missions', () {
    final progress = const CampaignProgress()
        .withCompleted(campaignMissions[0].id)
        .withCompleted('crossroads', choice: 1);
    final restored = CampaignProgress.fromJson(progress.toJson());
    expect(restored.completed, progress.completed);
    expect(restored.choices, {'crossroads': 1});
    final dirty = CampaignProgress.fromJson({
      'completed': ['ghost', 'first-roll'],
    });
    expect(dirty.completed, ['first-roll']);
  });

  test('a locked mission cannot be completed', () async {
    final gateway = MemoryCampaign();
    await CompleteMissionUseCase(gateway)(campaignMissions[2]);
    expect(gateway.current.doneCount, 0);
  });

  test('the cubit follows completion and reset', () async {
    final gateway = MemoryCampaign();
    final cubit = cubitOn(gateway);
    addTearDown(cubit.close);
    await cubit.complete(campaignMissions[0]);
    expect(cubit.state.isDone(campaignMissions[0].id), isTrue);
    await cubit.complete(campaignMissions[1]);
    expect(cubit.state.doneCount, 2);
    await cubit.reset();
    expect(cubit.state.doneCount, 0);
  });

  test('progress is persisted in the document store', () async {
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final gateway = CampaignGatewayImpl(DocumentStore(db));
    await gateway.save(
      const CampaignProgress().withCompleted(campaignMissions[0].id),
    );
    final reopened = CampaignGatewayImpl(DocumentStore(db));
    await reopened.load();
    expect(reopened.current.isDone(campaignMissions[0].id), isTrue);
  });
}
