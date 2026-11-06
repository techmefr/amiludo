import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/map_board.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/map_board_state.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_canvas.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_painter.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_tool.dart';

Widget _host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

double _scale(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.byWidgetPredicate((w) => w is CustomPaint && w.painter is MapPainter),
  );
  return (paint.painter! as MapPainter).view.scale;
}

void main() {
  for (final size in const [Size(390, 844), Size(1280, 720)]) {
    group('map at $size', () {
      late MapBoard board;

      Future<void> open(WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        board = const MapBoard();
        await tester.pumpWidget(
          _host(MapBoardTool(onChanged: (b) => board = b)),
        );
      }

      testWidgets('a pin is placed, edited and deleted', (tester) async {
        await open(tester);
        await tester.tap(find.byTooltip('Pin'));
        await tester.pump();
        await tester.tapAt(tester.getCenter(find.byType(MapCanvas)));
        await tester.pump();
        expect(board.markers, hasLength(1));
        await tester.tapAt(tester.getCenter(find.byType(MapCanvas)));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, 'Camp');
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        expect(board.markers.single.label, 'Camp');
        await tester.tapAt(tester.getCenter(find.byType(MapCanvas)));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
        expect(board.markers, isEmpty);
        await tester.tap(find.byTooltip('Undo'));
        await tester.pump();
        expect(board.markers, hasLength(1));
      });

      testWidgets('a token can be dragged with the move tool', (tester) async {
        await open(tester);
        await tester.tap(find.byTooltip('Token'));
        await tester.pump();
        final center = tester.getCenter(find.byType(MapCanvas));
        await tester.tapAt(center);
        await tester.tap(find.byTooltip('Move and zoom'));
        await tester.pump();
        final gesture = await tester.startGesture(center);
        for (var i = 0; i < 4; i++) {
          await gesture.moveBy(const Offset(30, 0));
          await tester.pump();
        }
        await gesture.up();
        await tester.pump();
        expect(board.markers.single.x, greaterThan(500));
      });

      testWidgets('lines and zones are drawn and can be erased', (
        tester,
      ) async {
        await open(tester);
        await tester.tap(find.byTooltip('Line'));
        await tester.pump();
        await tester.drag(find.byType(MapCanvas), const Offset(120, 0));
        await tester.pump();
        await tester.tap(find.byTooltip('Zone'));
        await tester.pump();
        await tester.drag(find.byType(MapCanvas), const Offset(0, 100));
        await tester.pump();
        expect(board.strokes.map((s) => s.kind), [
          MapStrokeKind.line,
          MapStrokeKind.zone,
        ]);
        await tester.tap(find.byTooltip('Erase'));
        await tester.pump();
        final center = tester.getCenter(find.byType(MapCanvas));
        await tester.tapAt(center + const Offset(60, 0));
        await tester.pump();
        expect(board.strokes, hasLength(1));
      });

      testWidgets('pinching zooms and the background can change', (
        tester,
      ) async {
        await open(tester);
        final center = tester.getCenter(find.byType(MapCanvas));
        final a = await tester.startGesture(center - const Offset(30, 0));
        final b = await tester.startGesture(center + const Offset(30, 0));
        for (var i = 0; i < 4; i++) {
          await a.moveBy(const Offset(-20, 0));
          await b.moveBy(const Offset(20, 0));
          await tester.pump();
        }
        await a.up();
        await b.up();
        await tester.pump();
        expect(_scale(tester), greaterThan(1));
        await tester.ensureVisible(find.byTooltip('Background'));
        await tester.tap(find.byTooltip('Background'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Hex grid'));
        await tester.pump();
        expect(board.background, MapBackground.hex);
      });
    });
  }
}
