import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_bundle.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_library.dart';
import 'package:amiludo/layers/functional/Companion/domain/gateways/die_gateways.dart';
import 'package:amiludo/layers/functional/Companion/domain/use_cases/die_share_use_cases.dart';
import 'package:amiludo/layers/functional/Companion/domain/use_cases/die_use_cases.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_editor_screen.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_face_view.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_library_screen.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_studio.dart';
import 'package:amiludo/layers/technical/Drawing/drawing_pad.dart';

class MemoryDieLibrary implements DieLibraryGateway {
  @override
  DieLibrary current = const DieLibrary();
  final _changes = StreamController<DieLibrary>.broadcast(sync: true);

  @override
  Stream<DieLibrary> get changes => _changes.stream;

  @override
  Future<void> save(DieLibrary library) async {
    current = library;
    _changes.add(library);
  }
}

class MemoryDieImages implements DieImageGateway {
  final store = <String, Uint8List>{};

  @override
  Future<Uint8List?> read(String id) async => store[id];

  @override
  Future<void> write(String id, List<int> bytes) async =>
      store[id] = Uint8List.fromList(bytes);

  @override
  Future<void> delete(String id) async => store.remove(id);
}

({DieStudioCubit cubit, MemoryDieLibrary library, MemoryDieImages images})
studio([List<DieDesign> designs = const []]) {
  final library = MemoryDieLibrary()..current = DieLibrary(designs);
  final images = MemoryDieImages();
  final cubit = DieStudioCubit(
    DieStudioActions(
      save: SaveDieUseCase(library, images),
      remove: RemoveDieUseCase(library, images),
      duplicate: DuplicateDieUseCase(library, images),
      readImage: ReadDieImageUseCase(images),
      export: ExportDiceUseCase(library, images),
      previewImport: PreviewDiceImportUseCase(library),
      import: ImportDiceUseCase(library, images),
    ),
    library.current,
    library.changes,
  );
  addTearDown(cubit.close);
  return (cubit: cubit, library: library, images: images);
}

Widget host(DieStudioCubit cubit, Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: DieStudio(cubit: cubit, child: child),
);

void useSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Uint8List tinyPng() {
  final data = ByteData(33);
  const sig = [137, 80, 78, 71, 13, 10, 26, 10];
  for (var i = 0; i < 8; i++) {
    data.setUint8(i, sig[i]);
  }
  data.setUint32(16, 4);
  data.setUint32(20, 4);
  return data.buffer.asUint8List();
}

void main() {
  group('use cases', () {
    test('save, duplicate with images, remove cleans images', () async {
      final s = studio();
      final design = DieDesign(
        id: 'a',
        name: 'Art',
        faces: const [
          DieFaceContent(kind: DieFaceKind.image, value: 'i1'),
          DieFaceContent(value: '2'),
        ],
      );
      await s.cubit.save(design, images: {'i1': tinyPng()});
      expect(s.library.current.designs, hasLength(1));
      await s.cubit.duplicate('a', 'Art (copy)');
      expect(s.library.current.designs, hasLength(2));
      expect(s.images.store, hasLength(2));
      await s.cubit.remove('a');
      expect(s.library.current.designs, hasLength(1));
      expect(s.images.store, hasLength(1));
    });

    test('export then import merges without overwriting', () async {
      final source = studio([DieDesign.standard('a', 'Mine', 6)]);
      final text = await source.cubit.export(['a']);
      final target = studio([DieDesign.standard('a', 'Other', 8)]);
      final preview = target.cubit.previewImport(text);
      expect(preview.clashes, {'a'});
      await target.cubit.import(preview.bundle, ClashPolicy.keepBoth);
      expect(target.library.current.designs.map((d) => d.name), [
        'Other',
        'Mine',
      ]);
      await target.cubit.import(preview.bundle, ClashPolicy.replace);
      expect(target.library.current.byId('a')!.name, 'Mine');
    });

    test('a whole selection travels in one file', () async {
      final s = studio([
        DieDesign.standard('a', 'A', 2),
        DieDesign.standard('b', 'B', 100),
      ]);
      final bundle = DieBundle.decode(await s.cubit.export(['a', 'b']));
      expect(bundle.designs.map((d) => d.sides), [2, 100]);
    });
  });

  group('embedding in shared files', () {
    test('a file carries its dice and import merges them', () async {
      final art = DieDesign(
        id: 'a',
        name: 'Art',
        faces: const [
          DieFaceContent(kind: DieFaceKind.image, value: 'i1'),
          DieFaceContent(value: '2'),
        ],
      );
      final source = studio();
      await source.cubit.save(art, images: {'i1': tinyPng()});
      final embed = EmbedDiceUseCase(
        ExportDiceUseCase(source.library, source.images),
        source.library,
      );
      final file = jsonEncode({
        'bricks': [
          {
            'settings': {
              'dice': [
                {'design': art.toJson()},
              ],
            },
          },
        ],
      });
      final embedded = await embed(file);
      expect(jsonDecode(embedded)['dice'], isNotNull);
      expect(await embed('{"x":1}'), '{"x":1}');

      final target = studio([DieDesign.standard('a', 'Other', 6)]);
      final read = ReadEmbeddedDiceUseCase(target.library)(embedded)!;
      expect(read.clashes, {'a'});
      final text = await AcceptEmbeddedDiceUseCase(
        ImportDiceUseCase(target.library, target.images),
      )(embedded, read.bundle, ClashPolicy.keepBoth);
      expect(target.library.current.designs, hasLength(2));
      final newId = target.library.current.designs.last.id;
      expect(newId, isNot('a'));
      expect(jsonDecode(text).containsKey('dice'), isFalse);
      expect(text, contains(newId));
      expect(target.images.store, hasLength(1));
    });

    test('a file without dice is left alone', () {
      final target = studio();
      expect(ReadEmbeddedDiceUseCase(target.library)('{"a":1}'), isNull);
    });
  });

  group('drawing pad', () {
    test('undo and clear', () {
      final c = DrawingController()
        ..begin(const Offset(1, 1))
        ..extend(const Offset(5, 5))
        ..begin(const Offset(9, 9));
      expect(c.strokes, hasLength(2));
      c.undo();
      expect(c.strokes, hasLength(1));
      c.clear();
      expect(c.isEmpty, isTrue);
    });
  });

  for (final size in const [Size(390, 844), Size(1280, 720)]) {
    group('screens at $size', () {
      testWidgets('library lists dice with labelled 44 px buttons', (
        tester,
      ) async {
        useSize(tester, size);
        final s = studio([DieDesign.standard('a', 'Mine', 6)]);
        await tester.pumpWidget(host(s.cubit, const DieLibraryScreen()));
        expect(find.text('Mine'), findsOneWidget);
        expect(find.text('6 faces'), findsOneWidget);
        for (final tip in [
          'Edit die',
          'Duplicate die',
          'Export die',
          'Delete die',
          'Import dice',
        ]) {
          final button = find.byTooltip(tip);
          expect(button, findsOneWidget, reason: tip);
          final box = tester.getSize(button);
          expect(box.width, greaterThanOrEqualTo(44), reason: tip);
          expect(box.height, greaterThanOrEqualTo(44), reason: tip);
        }
        await tester.tap(find.byTooltip('Duplicate die'));
        await tester.pumpAndSettle();
        expect(find.text('Mine (copy)'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('editor stays usable with 100 faces', (tester) async {
        useSize(tester, size);
        final s = studio();
        await tester.pumpWidget(
          host(
            s.cubit,
            Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DieStudio(
                      cubit: s.cubit,
                      child: DieEditorScreen(
                        initial: DieDesign.standard('a', 'Big', 100),
                      ),
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(find.text('100 faces'), findsWidgets);
        await tester.scrollUntilVisible(
          find.text('Save'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(s.library.current.byId('a')!.sides, 100);
        expect(tester.takeException(), isNull);
      });

      testWidgets('face view renders text and icons', (tester) async {
        useSize(tester, size);
        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: const [
                DieFaceView(
                  face: DieFaceContent(value: '7'),
                  body: Colors.blue,
                ),
                DieFaceView(
                  face: DieFaceContent(kind: DieFaceKind.icon, value: 'star'),
                  body: Colors.blue,
                ),
              ],
            ),
          ),
        );
        expect(find.text('7'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  }
}
