import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/dependencies.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/library_gateway.dart';
import 'package:amiludo/layers/functional/Library/presentation/bookshelf.dart';
import 'package:amiludo/layers/functional/Library/presentation/game_cards.dart';
import 'package:amiludo/layers/technical/Barcode/barcode_scanner_view.dart';
import 'package:amiludo/layers/technical/Barcode/scan_frame.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

Future<void> _open(WidgetTester tester, Size size, String path) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final db = StoreDatabase.forTesting(NativeDatabase.memory());
  configureDependencies(db);
  addTearDown(getIt.reset);
  getIt.unregister<BarcodeScannerBuilder>();
  getIt.registerSingleton<BarcodeScannerBuilder>(
    (onCode, unavailable) => const ColoredBox(color: Color(0xff222222)),
  );
  await tester.pumpWidget(const AmiludoApp());
  router.go(path);
  await tester.pumpAndSettle();
}

Finder segment(String label) => find.descendant(
  of: find.byType(SegmentedButton<bool>),
  matching: find.text(label),
);

void main() {
  testWidgets(
    'scan frame labels itself, reacts to busy and stops in reduced motion',
    (tester) async {
      Widget host({
        required bool busy,
        required bool reduced,
        Brightness? dark,
      }) => MaterialApp(
        theme: ThemeData(brightness: dark ?? Brightness.light),
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: SizedBox(
            width: 400,
            height: 300,
            child: ScanFrame(
              busy: busy,
              label: 'frame-label',
              child: const ColoredBox(color: Color(0xff000000)),
            ),
          ),
        ),
      );
      await tester.pumpWidget(host(busy: false, reduced: false));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.bySemanticsLabel('frame-label'), findsOneWidget);
      await tester.pumpWidget(
        host(busy: true, reduced: false, dark: Brightness.dark),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(host(busy: false, reduced: true));
      await tester.pumpAndSettle();
      expect(find.byType(ScanFrame), findsOneWidget);
    },
  );

  for (final size in const [Size(390, 844), Size(820, 1180), Size(1440, 900)]) {
    testWidgets('scan screen lays out at $size without overflow', (
      tester,
    ) async {
      await _open(tester, size, '/library/scan');
      expect(find.byType(ScanFrame), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('empty shelf shows its illustration, cards and shelf switch', (
    tester,
  ) async {
    await _open(tester, const Size(1440, 1100), '/library');
    expect(find.byType(Image), findsWidgets);
    await getIt<LibraryGateway>().save(
      const Shelf(
        games: [
          ShelfGame(id: 'a', name: 'Catan'),
          ShelfGame(id: 'b', name: 'Skull', status: 'wishlist'),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(GameSpine), findsNWidgets(2));
    await tester.tap(segment('Cartes'));
    await tester.pumpAndSettle();
    expect(find.byType(GameCard), findsNWidgets(2));
    expect(find.byType(GameSpine), findsNothing);
    await tester.tap(segment('Étagère'));
    await tester.pumpAndSettle();
    expect(find.byType(GameSpine), findsNWidgets(2));
    await tester.pumpWidget(const SizedBox());
  });
}
