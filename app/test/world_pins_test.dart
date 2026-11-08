import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/World/domain/entities/map_element.dart';
import 'package:amiludo/layers/functional/World/domain/entities/map_pin.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_atlas.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_map.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_map_pins.dart';
import 'package:amiludo/layers/functional/World/domain/use_cases/world_atlas_use_cases.dart';
import 'package:amiludo/layers/functional/World/presentation/world_tool.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/export_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/import_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/load_workspace_use_case.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

MapPin pin(
  String id,
  String title, {
  PinKind kind = PinKind.place,
  String? refId,
  String? childMapId,
}) => MapPin(
  id: id,
  kind: kind,
  point: const WorldPoint(10, 20),
  title: title,
  refId: refId,
  childMapId: childMapId,
);

Widget host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SizedBox(height: 600, child: child)),
);

void main() {
  _domainTests();
  _widgetTests();
  _backupTests();
}

void _domainTests() {
  test('pins are added, updated, moved and removed on a floor', () {
    var map = WorldMap.create('Town', ScaleLevel.city);
    final floorId = map.floors.single.id;
    map = map.addPin(floorId, pin('p1', 'Inn'));
    expect(map.floors.single.pins.single.title, 'Inn');
    map = map.updatePin(
      pin('p1', 'Tavern').copyWith(point: const WorldPoint(5, 5)),
    );
    expect(map.floors.single.pins.single.title, 'Tavern');
    expect(map.floors.single.pins.single.point.x, 5);
    map = map.removePin('p1');
    expect(map.floors.single.pins, isEmpty);
  });

  test('pins survive a json round trip', () {
    final original = pin(
      'p1',
      'Crypt',
      kind: PinKind.danger,
      refId: 'c1',
      childMapId: 'm2',
    );
    final back = MapPin.fromJson(original.toJson());
    expect(back.kind, PinKind.danger);
    expect(back.refId, 'c1');
    expect(back.childMapId, 'm2');
    expect(back.point.y, 20);
  });

  test('distances are measured in meters from the map scale', () {
    final map = WorldMap.create('Town', ScaleLevel.city);
    final meters = map.metersBetween(
      const WorldPoint(0, 0),
      const WorldPoint(gridCell * 2, 0),
    );
    expect(meters, map.level.cellMeters * 2);
    expect(formatMeters(0.2), '1 m');
    expect(formatMeters(250), '250 m');
    expect(formatMeters(1500), '1.5 km');
    expect(formatMeters(25000), '25 km');
  });

  test('search finds pins across maps and ignores case and accents', () {
    var town = WorldMap.create('Town', ScaleLevel.city);
    town = town.addPin(town.floors.single.id, pin('p1', 'Auberge du Dragon'));
    var keep = WorldMap.create('Keep', ScaleLevel.building);
    keep = keep.addPin(keep.floors.single.id, pin('p2', 'Cellar'));
    final atlas = WorldAtlas(maps: [town, keep]);
    expect(atlas.searchPins('').length, 2);
    expect(atlas.searchPins('DRAGON').single.pin.id, 'p1');
    expect(atlas.searchPins('dragon').single.map.name, 'Town');
    expect(atlas.searchPins('cel').single.map.name, 'Keep');
    expect(atlas.searchPins('nothing'), isEmpty);
  });

  test('scene pins give the place name of a scene', () {
    var town = WorldMap.create('Town', ScaleLevel.city);
    town = town.addPin(
      town.floors.single.id,
      pin('p1', 'Market', kind: PinKind.scene, refId: 's1'),
    );
    town = town.addPin(town.floors.single.id, pin('p2', 'Inn'));
    final names = WorldAtlas(maps: [town]).placeNamesByScene();
    expect(names, {'s1': 'Market'});
  });

  test('removing a map unlinks the pins that opened it', () {
    final town = WorldMap.create('Town', ScaleLevel.city);
    final keep = WorldMap.create('Keep', ScaleLevel.building);
    final linked = town.addPin(
      town.floors.single.id,
      pin('p1', 'Castle', childMapId: keep.id),
    );
    final atlas = WorldAtlas(maps: [linked, keep]).remove(keep.id);
    expect(atlas.maps.single.floors.single.pins.single.childMapId, isNull);
    expect(atlas.maps.single.floors.single.pins.single.title, 'Castle');
  });

  test('pins are part of the export and import', () {
    var town = WorldMap.create('Town', ScaleLevel.city);
    town = town.addPin(town.floors.single.id, pin('p1', 'Inn'));
    final text = WorldAtlas(maps: [town]).export();
    final result = const WorldAtlas().import(text)!;
    expect(result.merged.searchPins('inn').length, 1);
  });
}

void _widgetTests() {
  testWidgets('a pin is placed with the pin tool and the search opens', (
    tester,
  ) async {
    WorldAtlas? saved;
    await tester.pumpWidget(
      host(
        WorldTool(
          initial: WorldAtlas(maps: [WorldMap.create('Town', ScaleLevel.city)]),
          onChanged: (a) => saved = a,
        ),
      ),
    );
    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Pin'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Pin'));
    await tester.pump();
    await tester.tapAt(const Offset(200, 250));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Inn');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(saved!.searchPins('inn').single.pin.title, 'Inn');

    await tester.tap(find.byTooltip('Search places'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('No pin found.'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });
}

void _backupTests() {
  tearDown(getIt.reset);

  test('pins are restored with the backup', () async {
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(db);
    await getIt<LoadWorkspaceUseCase>()();
    var map = WorldMap.create('Realm', ScaleLevel.world);
    map = map.addPin(map.floors.single.id, pin('p1', 'Capital'));
    await getIt<SaveWorldAtlasUseCase>()(WorldAtlas(maps: [map]));
    final exported = getIt<ExportBackupUseCase>()();
    await getIt<SaveWorldAtlasUseCase>()(const WorldAtlas());
    await getIt<ImportBackupUseCase>()(exported);
    expect(
      getIt<ReadWorldAtlasUseCase>()().searchPins('capital').single.pin.id,
      'p1',
    );
    await db.close();
  });
}
