import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/domain/gateways/notebook_gateways.dart';
import 'package:amiludo/layers/functional/Notebook/domain/use_cases/notebook_use_cases.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/erase_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/export_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/import_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/load_workspace_use_case.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

Future<StoreDatabase> _open() async {
  final db = StoreDatabase.forTesting(NativeDatabase.memory());
  configureDependencies(db);
  await getIt<LoadWorkspaceUseCase>()();
  return db;
}

Map<String, dynamic> _backup() =>
    jsonDecode(getIt<ExportBackupUseCase>()()) as Map<String, dynamic>;

void main() {
  tearDown(getIt.reset);

  test('the backup has no notebook section while it is empty', () async {
    final db = await _open();
    expect(_backup().containsKey('campaigns'), isFalse);
    await db.close();
  });

  test('campaigns round trip through backup, export file and erase', () async {
    final db = await _open();
    final save = getIt<SaveCampaignUseCase>();
    final campaign = NotebookCampaign.create('Tides', CampaignKind.gm);
    await save(campaign.copyWith(favorite: true));
    final text = getIt<ExportBackupUseCase>()();
    expect(_backup()['campaigns'], hasLength(1));

    await getIt<EraseWorkspaceUseCase>()();
    expect(getIt<NotebookGateway>().current.isEmpty, isTrue);

    await getIt<ImportBackupUseCase>()(text);
    final restored = getIt<NotebookGateway>().current.campaigns.single;
    expect(restored.title, 'Tides');
    expect(restored.favorite, isTrue);

    final file = await getIt<ExportCampaignUseCase>()(campaign.id);
    final id = await getIt<ImportCampaignUseCase>()(file);
    expect(id, isNot(campaign.id));
    expect(getIt<NotebookGateway>().current.campaigns, hasLength(2));
    await getIt<DeleteCampaignUseCase>()(id);
    expect(getIt<NotebookGateway>().current.campaigns, hasLength(1));
    await db.close();
  });

  test('images travel with a campaign file and are pruned', () async {
    final db = await _open();
    final images = getIt<NotebookImageGateway>();
    final imageId = await getIt<ImportNotebookImageUseCase>()([9, 8, 7]);
    final campaign = NotebookCampaign.create(
      'Art',
      CampaignKind.solo,
    ).withLook(headerImageId: imageId);
    await getIt<SaveCampaignUseCase>()(campaign);
    final file = await getIt<ExportCampaignUseCase>()(campaign.id);
    final copyId = await getIt<ImportCampaignUseCase>()(file);
    final copy = getIt<NotebookGateway>().current.of(copyId)!;
    expect(await images.read(copy.headerImageId!), [9, 8, 7]);
    await getIt<DeleteCampaignUseCase>()(campaign.id);
    expect(await images.read(imageId), isNull);
    expect(await images.read(copy.headerImageId!), isNotNull);
    await db.close();
  });
}
