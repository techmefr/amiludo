import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_mode_selector.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_options.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_surface.dart';
import 'package:amiludo/layers/functional/Templates/presentation/session_stage.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/layers/technical/Theme/components/finger_layers.dart';
import 'package:amiludo/layers/technical/Theme/components/finger_ring.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_tab_strip.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';

const _sizes = [
  Size(375, 812),
  Size(768, 1024),
  Size(1280, 720),
  Size(844, 390),
];

const _bricks = [
  Brick(id: 'a', type: 'dice'),
  Brick(id: 'b', type: 'roles'),
  Brick(id: 'c', type: 'teams'),
  Brick(id: 'd', type: 'picker'),
  Brick(id: 'e', type: 'hourglass'),
  Brick(id: 'f', type: 'life'),
];

Widget _stage() => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: SessionStage(
    sessionId: 'top',
    title: 'Session',
    bricks: _bricks,
    builder: (context, brick) => Center(child: Text('body ${brick.id}')),
    initial: 0,
    onGrid: () {},
  ),
);

void _size(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<StoreDatabase> _app(WidgetTester tester, String route) async {
  final db = StoreDatabase.forTesting(NativeDatabase.memory());
  configureDependencies(db);
  addTearDown(getIt.reset);
  await tester.pumpWidget(const AmiludoApp());
  await tester.pumpAndSettle();
  router.go(route);
  await tester.pumpAndSettle();
  return db;
}

Future<void> _close(WidgetTester tester, StoreDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await db.close();
}

void main() {
  for (final size in _sizes) {
    group('top bar at ${size.width.toInt()}x${size.height.toInt()}', () {
      testWidgets('back, tabs and switcher share one compact row', (
        tester,
      ) async {
        _size(tester, size);
        await tester.pumpWidget(_stage());
        await tester.pumpAndSettle();
        final back = tester.getRect(find.byType(BackButtonIcon));
        final strip = tester.getRect(find.byType(ToolTabStrip));
        expect((strip.center.dy - back.center.dy).abs(), lessThan(Space.sm));
        expect(strip.top, lessThan(Targets.minimum + Space.sm));
        expect(strip.left, greaterThan(back.right));
        expect(strip.right, lessThanOrEqualTo(size.width));
        expect(tester.takeException(), isNull);
      });

      testWidgets('tabs are 44dp targets with semantics and switch tools', (
        tester,
      ) async {
        _size(tester, size);
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_stage());
        await tester.pumpAndSettle();
        final first = tester
            .widget<Text>(
              find
                  .descendant(
                    of: find.byType(ToolTabStrip),
                    matching: find.byType(Text),
                  )
                  .first,
            )
            .data!;
        expect(find.bySemanticsLabel(first), findsWidgets);
        final target = find.descendant(
          of: find.byType(ToolTabStrip),
          matching: find.byType(InkWell),
        );
        for (var i = 0; i < 2; i++) {
          final rect = tester.getRect(target.at(i));
          expect(rect.height, greaterThanOrEqualTo(Targets.minimum));
          expect(rect.width, greaterThanOrEqualTo(Targets.minimum));
        }
        expect(find.text('body a'), findsOneWidget);
        await tester.ensureVisible(target.at(1));
        await tester.pumpAndSettle();
        await tester.tap(target.at(1));
        await tester.pumpAndSettle();
        expect(find.text('body b'), findsOneWidget);
        handle.dispose();
      });

      testWidgets('tabs scroll horizontally when they do not fit', (
        tester,
      ) async {
        _size(tester, size);
        await tester.pumpWidget(_stage());
        await tester.pumpAndSettle();
        final scroll = tester.state<ScrollableState>(
          find.descendant(
            of: find.byType(ToolTabStrip),
            matching: find.byType(Scrollable),
          ),
        );
        if (size.width < 800) {
          expect(scroll.position.maxScrollExtent, greaterThan(0));
        }
        await tester.drag(find.byType(ToolTabStrip), const Offset(-120, 0));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('dice top bar holds back and configure, 2D and 3D inside', (
        tester,
      ) async {
        _size(tester, size);
        final db = await _app(tester, '/tools/dice');
        await tester.pump();
        final configure = tester.getRect(find.byTooltip('Configurer'));
        expect(configure.top, lessThan(Targets.minimum + Space.sm));
        final back = tester.getRect(find.byType(BackButtonIcon));
        expect(
          (configure.center.dy - back.center.dy).abs(),
          lessThan(Space.md),
        );
        expect(find.text('3D'), findsNothing);
        await tester.tap(find.byTooltip('Configurer'));
        await tester.pumpAndSettle();
        expect(find.text('2D'), findsOneWidget);
        expect(find.text('3D'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await _close(tester, db);
      });
    });
  }

  for (final size in _sizes) {
    group('finger tool at ${size.width.toInt()}x${size.height.toInt()}', () {
      testWidgets('the whole screen is the touch surface', (tester) async {
        _size(tester, size);
        final db = await _app(tester, '/tools/picker');
        final rect = tester.getRect(find.byType(FingerSurface));
        expect(rect, Offset.zero & size);
        expect(find.byType(BackButtonIcon), findsOneWidget);
        expect(tester.takeException(), isNull);
        await _close(tester, db);
      });

      testWidgets('three fingers get halos and countdown, then one wins', (
        tester,
      ) async {
        _size(tester, size);
        final db = await _app(tester, '/tools/picker');
        final c = size.center(Offset.zero);
        final a = await tester.startGesture(c + const Offset(-120, 0));
        final b = await tester.startGesture(c + const Offset(120, 0));
        final d = await tester.startGesture(c + const Offset(0, 90));
        await tester.pump();
        expect(find.byType(FingerHalo), findsNWidgets(3));
        expect(find.byType(FingerCountdownArc), findsNWidgets(3));
        await tester.pump(const Duration(seconds: 2));
        final states = tester
            .widgetList<FingerRing>(find.byType(FingerRing))
            .map((r) => r.state);
        expect(states.where((s) => s == FingerRingState.winner), hasLength(1));
        expect(states.where((s) => s == FingerRingState.dim), hasLength(2));
        expect(find.byType(FingerShockwave), findsOneWidget);
        await a.up();
        await b.up();
        await d.up();
        await tester.pumpAndSettle();
        await _close(tester, db);
      });

      testWidgets('team mode splits every finger into a group', (tester) async {
        _size(tester, size);
        final db = await _app(tester, '/tools/picker');
        final third = find
            .descendant(
              of: find.byType(SegmentedButton<FingerMode>),
              matching: find.byType(Text),
            )
            .at(2);
        await tester.ensureVisible(third);
        await tester.pumpAndSettle();
        await tester.tap(third);
        await tester.pumpAndSettle();
        final c = size.center(Offset.zero);
        final fingers = [
          await tester.startGesture(c + const Offset(-150, 0)),
          await tester.startGesture(c + const Offset(0, 0)),
          await tester.startGesture(c + const Offset(150, 0)),
        ];
        await tester.pump(const Duration(seconds: 2));
        final labels = tester
            .widgetList<FingerRing>(find.byType(FingerRing))
            .map((r) => r.label)
            .toList();
        expect(labels, everyElement(isIn(['1', '2'])));
        expect(labels, hasLength(3));
        for (final f in fingers) {
          await f.up();
        }
        await tester.pumpAndSettle();
        await _close(tester, db);
      });

      testWidgets('options live in a bottom sheet', (tester) async {
        _size(tester, size);
        final db = await _app(tester, '/tools/picker');
        await tester.tap(find.byIcon(Icons.tune_rounded));
        await tester.pumpAndSettle();
        expect(find.byType(FingerOptions), findsOneWidget);
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        expect(find.text('2'), findsOneWidget);
        await _close(tester, db);
      });
    });
  }

  testWidgets('a mouse adds and removes simulated fingers', (tester) async {
    _size(tester, const Size(1280, 720));
    final db = await _app(tester, '/tools/picker');
    Future<void> click(Offset at) async {
      final g = await tester.startGesture(at, kind: PointerDeviceKind.mouse);
      await g.up();
      await tester.pump();
    }

    await click(const Offset(400, 300));
    await click(const Offset(800, 400));
    expect(find.byType(FingerRing), findsNWidgets(2));
    await click(const Offset(800, 400));
    expect(find.byType(FingerRing), findsNWidgets(1));
    await click(const Offset(800, 400));
    await tester.pump(const Duration(seconds: 2));
    final states = tester
        .widgetList<FingerRing>(find.byType(FingerRing))
        .map((r) => r.state);
    expect(states.where((s) => s == FingerRingState.winner), hasLength(1));
    await click(const Offset(200, 200));
    expect(find.byType(FingerRing), findsNothing);
    await tester.pumpAndSettle();
    await _close(tester, db);
  });

  testWidgets('reduced motion drops the shockwave and animates nothing', (
    tester,
  ) async {
    _size(tester, const Size(390, 844));
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final db = await _app(tester, '/tools/picker');
    final a = await tester.startGesture(const Offset(100, 300));
    final b = await tester.startGesture(const Offset(260, 420));
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(FingerShockwave), findsWidgets);
    expect(find.byType(CustomPaint), findsWidgets);
    final wave = tester.widget<FingerShockwave>(
      find.byType(FingerShockwave).first,
    );
    expect(wave, isNotNull);
    expect(
      find.descendant(
        of: find.byType(FingerShockwave),
        matching: find.byType(TweenAnimationBuilder<double>),
      ),
      findsNothing,
    );
    await a.up();
    await b.up();
    await tester.pumpAndSettle();
    await _close(tester, db);
  });
}
