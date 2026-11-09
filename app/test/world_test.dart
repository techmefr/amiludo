import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/World/domain/entities/map_element.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_atlas.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_map.dart';
import 'package:amiludo/layers/functional/World/domain/use_cases/world_atlas_use_cases.dart';
import 'package:amiludo/layers/functional/World/presentation/world_tool.dart';
import 'package:amiludo/layers/functional/World/presentation/world_viewport.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/export_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/import_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/load_workspace_use_case.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

MapElement stroke(String id, ElementKind kind, List<WorldPoint> points) =>
    MapElement(id: id, kind: kind, points: points);

Widget host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SizedBox(height: 600, child: child)),
);

void main() {
  _domainTests();
  _viewportTests();
  _widgetTests();
  _backupTests();
}

void _domainTests() {
  test('floors are added above and below and named by number', () {
    var map = WorldMap.create('Keep', ScaleLevel.building);
    expect(map.floors.single.name, '0');
    expect(map.nextFloorName(), '1');
    expect(map.nextFloorName(below: true), '-1');
    map = map.addFloor('1').addFloor('-1', below: true);
    expect([for (final f in map.floors) f.name], ['-1', '0', '1']);
    expect(map.below(map.floors[1].id)!.name, '-1');
    expect(map.below(map.floors.first.id), isNull);
  });

  test('stairs link both floors and are removed together', () {
    var map = WorldMap.create('Keep', ScaleLevel.building).addFloor('1');
    final ground = map.floors.first.id, upper = map.floors.last.id;
    map = map.addElement(
      ground,
      stroke('s1', ElementKind.stairs, const [WorldPoint(10, 10)]),
    );
    expect(map.floor(ground)!.elements.single.target, upper);
    expect(map.floor(upper)!.elements.single.target, ground);
    expect(map.removeElement('s1p').floor(ground)!.elements, isEmpty);
    expect(map.removeElement('s1').floor(upper)!.elements, isEmpty);
  });

  test('removing a floor drops the stairs that led to it', () {
    var map = WorldMap.create('Keep', ScaleLevel.building).addFloor('1');
    final ground = map.floors.first.id, upper = map.floors.last.id;
    map = map.addElement(
      ground,
      stroke('s1', ElementKind.stairs, const [WorldPoint(0, 0)]),
    );
    map = map.removeFloor(upper);
    expect(map.floors.length, 1);
    expect(map.floors.single.elements, isEmpty);
    expect(map.removeFloor(ground).floors.length, 1);
  });

  test('the nearest element is found within reach and undo pops it', () {
    var map = WorldMap.create('Isle', ScaleLevel.region);
    final id = map.floors.single.id;
    map = map
        .addElement(
          id,
          stroke('a', ElementKind.road, const [
            WorldPoint(0, 0),
            WorldPoint(100, 0),
          ]),
        )
        .addElement(
          id,
          stroke('b', ElementKind.room, const [
            WorldPoint(200, 200),
            WorldPoint(260, 240),
          ]),
        );
    final floor = map.floor(id)!;
    expect(floor.nearest(const WorldPoint(50, 4), 8)!.id, 'a');
    expect(floor.nearest(const WorldPoint(230, 220), 1)!.id, 'b');
    expect(floor.nearest(const WorldPoint(50, 60), 8), isNull);
    expect(map.undo(id).floor(id)!.elements.single.id, 'a');
  });

  test('brush strokes are hit across their width', () {
    final blob = MapElement(
      id: 'w',
      kind: ElementKind.water,
      points: const [WorldPoint(0, 0), WorldPoint(100, 0)],
      width: 40,
    );
    expect(blob.distanceTo(const WorldPoint(50, 15)) <= 0, isTrue);
    expect(blob.distanceTo(const WorldPoint(50, 60)) > 0, isTrue);
  });

  test('an atlas exports, imports and merges', () {
    final map = WorldMap.create(
      'Realm',
      ScaleLevel.world,
    ).addElement('x', stroke('a', ElementKind.land, const [WorldPoint(1, 2)]));
    final atlas = WorldAtlas(maps: [map]);
    final result = const WorldAtlas().import(atlas.export());
    expect(result!.count, 1);
    expect(result.merged.maps.single.name, 'Realm');
    expect(const WorldAtlas().import('nope'), isNull);
    expect(const WorldAtlas().import('[]'), isNull);
    final back = WorldAtlas.fromJson(atlas.toJson());
    expect(back.maps.single.level, ScaleLevel.world);
    expect(ScaleLevel.city.cellLabel, '100 m');
    expect(ScaleLevel.world.cellLabel, '100 km');
  });
}

void _viewportTests() {
  test('zooming keeps the point under the finger in place', () {
    const view = WorldViewport(scale: 1, offset: Offset(100, 50));
    const focal = Offset(300, 200);
    final before = view.toWorld(focal);
    final zoomed = view.zoomedBy(2, focal);
    final after = zoomed.toWorld(focal);
    expect(zoomed.scale, 2);
    expect((after.x - before.x).abs() < 1e-9, isTrue);
    expect((after.y - before.y).abs() < 1e-9, isTrue);
    expect(view.zoomed(1000, focal).scale, worldMaxZoom);
    expect(view.zoomed(0.0001, focal).scale, worldMinZoom);
  });
}

void _widgetTests() {
  testWidgets('a map is created, floors are added and a stroke is drawn', (
    tester,
  ) async {
    WorldAtlas? saved;
    await tester.pumpWidget(host(WorldTool(onChanged: (a) => saved = a)));
    expect(find.text('No map yet. Create your first map.'), findsOneWidget);
    await tester.tap(find.text('New map'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Map name'), 'Realm');
    await tester.tap(find.text('Create map'));
    await tester.pumpAndSettle();
    expect(saved!.maps.single.name, 'Realm');
    expect(find.text('Floor 0'), findsOneWidget);

    await tester.tap(find.byTooltip('Floor options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add a floor above'));
    await tester.pumpAndSettle();
    expect(find.text('Floor 1'), findsOneWidget);
    expect(saved!.maps.single.floors.length, 2);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Land'));
    await tester.pump();
    await tester.dragFrom(const Offset(200, 250), const Offset(120, 40));
    await tester.pump();
    final floor = saved!.maps.single.floors.last;
    expect(floor.elements.single.kind, ElementKind.land);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });

  testWidgets('the grid toggles and the zoom buttons respond', (tester) async {
    WorldAtlas? saved;
    await tester.pumpWidget(
      host(
        WorldTool(
          initial: WorldAtlas(maps: [WorldMap.create('Town', ScaleLevel.city)]),
          onChanged: (a) => saved = a,
        ),
      ),
    );
    expect(find.text('1 cell = 100 m'), findsOneWidget);
    await tester.tap(find.byTooltip('Map options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show the grid'));
    await tester.pumpAndSettle();
    expect(saved!.maps.single.grid, isTrue);
    await tester.tap(find.byTooltip('Zoom in'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Fit the view'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

void _backupTests() {
  tearDown(getIt.reset);

  test('the atlas is part of the backup and restores', () async {
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(db);
    await getIt<LoadWorkspaceUseCase>()();
    final map = WorldMap.create('Realm', ScaleLevel.world);
    await getIt<SaveWorldAtlasUseCase>()(WorldAtlas(maps: [map]));
    final exported = getIt<ExportBackupUseCase>()();
    await getIt<SaveWorldAtlasUseCase>()(const WorldAtlas());
    await getIt<ImportBackupUseCase>()(exported);
    expect(getIt<ReadWorldAtlasUseCase>()().maps.single.name, 'Realm');
    await db.close();
  });
}
