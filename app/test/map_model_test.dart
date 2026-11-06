import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/map_board.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/map_board_state.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/map_boards.dart';
import 'package:amiludo/layers/functional/Companion/domain/use_cases/map_use_cases.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_controller.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_geometry.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/erase_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/export_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/import_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/load_workspace_use_case.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

MapBoard _sample() => const MapBoard(
  background: MapBackground.hex,
  markers: [
    MapMarker(
      id: 'a',
      x: 100,
      y: 200,
      kind: MapMarkerKind.token,
      label: 'Ogre',
    ),
  ],
  strokes: [
    MapStroke(
      id: 's',
      kind: MapStrokeKind.zone,
      points: [MapPoint(0, 0), MapPoint(50, 0), MapPoint(50, 50)],
    ),
  ],
);

Map<String, dynamic> _decode(String text) =>
    Map<String, dynamic>.from(jsonDecode(text) as Map);

void main() {
  tearDown(getIt.reset);

  test('a board survives a JSON round trip', () {
    final back = MapBoard.fromJson(_decode(jsonEncode(_sample().toJson())));
    expect(back.background, MapBackground.hex);
    expect(back.markers.single.kind, MapMarkerKind.token);
    expect(back.markers.single.label, 'Ogre');
    expect(back.strokes.single.kind, MapStrokeKind.zone);
    expect(back.strokes.single.points, hasLength(3));
  });

  test('coordinates outside the sheet are clamped when read', () {
    final marker = MapMarker.fromJson({'id': 'a', 'x': -40, 'y': 5000});
    expect(marker.x, 0);
    expect(marker.y, mapWorld);
  });

  test('a blank board is empty and is dropped from the collection', () {
    expect(const MapBoard().isEmpty, isTrue);
    expect(_sample().isEmpty, isFalse);
    final boards = const MapBoards().put('g', _sample());
    expect(boards.of('g').markers, hasLength(1));
    expect(boards.put('g', const MapBoard()).isEmpty, isTrue);
  });

  test('undo walks back through every edit', () {
    final changes = <MapBoard>[];
    final c = MapController(const MapBoard(), onChanged: changes.add);
    c.addMarker(MapMarkerKind.pin, const MapPoint(10, 10));
    c.setBackground(MapBackground.grid);
    final id = c.board.markers.single.id;
    c.editMarker(c.board.markers.single.copyWith(label: 'Camp'));
    c.removeMarker(id);
    expect(c.board.markers, isEmpty);
    c.undo();
    expect(c.board.markers.single.label, 'Camp');
    c.undo();
    c.undo();
    expect(c.board.background, MapBackground.blank);
    c.undo();
    expect(c.board.markers, isEmpty);
    expect(c.canUndo, isFalse);
    expect(changes, isNotEmpty);
  });

  test('a drawn stroke needs two points and can be erased', () {
    final c = MapController(const MapBoard())..select(MapTool.zone);
    c.beginStroke(const MapPoint(1, 1));
    c.endStroke();
    expect(c.board.strokes, isEmpty);
    c.beginStroke(const MapPoint(1, 1));
    c.extendStroke(const MapPoint(80, 80));
    c.endStroke();
    expect(c.board.strokes.single.kind, MapStrokeKind.zone);
    c.eraseStroke(c.board.strokes.single.id);
    expect(c.board.strokes, isEmpty);
  });

  test('the view converts between screen and board coordinates', () {
    const view = MapView(fit: 0.5, scale: 2, offset: Offset(10, 20));
    final screen = view.toScreen(const MapPoint(100, 200));
    expect(screen, const Offset(110, 220));
    final world = view.toWorld(screen);
    expect(world.x, 100);
    expect(world.y, 200);
    const marker = MapMarker(id: 'm', x: 100, y: 200);
    expect(view.markerAt([marker], view.markerCenter(marker)), marker);
    expect(view.markerAt([marker], Offset.zero), isNull);
  });

  group('persistence', () {
    Future<StoreDatabase> open() async {
      final db = StoreDatabase.forTesting(NativeDatabase.memory());
      configureDependencies(db);
      await getIt<LoadWorkspaceUseCase>()();
      return db;
    }

    test('maps are kept per game and left out of an empty backup', () async {
      final db = await open();
      expect(_decode(getIt<ExportBackupUseCase>()()), isNot(contains('maps')));
      await getIt<SaveMapUseCase>()('g1', _sample());
      expect(getIt<ReadMapUseCase>()('g1').markers, hasLength(1));
      expect(getIt<ReadMapUseCase>()('g2').isEmpty, isTrue);
      final backup = getIt<ExportBackupUseCase>()();
      expect(_decode(backup)['maps'], contains('g1'));
      await getIt<EraseWorkspaceUseCase>()();
      expect(getIt<ReadMapUseCase>()('g1').isEmpty, isTrue);
      await getIt<ImportBackupUseCase>()(backup);
      expect(getIt<ReadMapUseCase>()('g1').markers.single.label, 'Ogre');
      await getIt<SaveMapUseCase>()('g1', const MapBoard());
      expect(_decode(getIt<ExportBackupUseCase>()()), isNot(contains('maps')));
      await db.close();
    });

    test('a replaced background image is deleted once unused', () async {
      final db = await open();
      final id = await getIt<ImportMapImageUseCase>()([1, 2, 3]);
      await getIt<SaveMapUseCase>()(
        'g1',
        const MapBoard().withBackground(MapBackground.image, imageId: id),
      );
      expect(await getIt<ReadMapImageUseCase>()(id), isNotNull);
      await getIt<SaveMapUseCase>()('g1', _sample());
      expect(await getIt<ReadMapImageUseCase>()(id), isNull);
      await db.close();
    });
  });
}
