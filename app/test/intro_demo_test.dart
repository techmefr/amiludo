import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/technical/Theme/components/demo/demo_player.dart';
import 'package:amiludo/layers/technical/Theme/components/demo/demo_tiles.dart';
import 'package:amiludo/layers/technical/Theme/components/intro/intro_gate.dart';
import 'package:amiludo/layers/technical/Theme/components/intro/intro_overlay.dart';
import 'package:amiludo/layers/technical/Theme/components/intro/intro_timeline.dart';

const _sizes = {
  'phone 375': Size(375, 812),
  'tablet 768': Size(768, 1024),
  'desktop 1280': Size(1280, 720),
};

Widget _host(Widget child, {bool reduced = false}) => MaterialApp(
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
      child: Scaffold(body: child),
    ),
  ),
);

Widget _gate(VoidCallback onDone) => IntroGate(
  words: const ['Vos jeux.', 'Vos amis.', 'Vos règles.'],
  skipLabel: 'Passer',
  onDone: onDone,
  child: const Text('app'),
);

void _size(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUp(() {
    IntroGate.enabled = true;
    IntroGate.resetSession();
    DemoPlayer.autoplay = true;
  });
  tearDown(() {
    IntroGate.enabled = false;
    DemoPlayer.autoplay = false;
  });

  for (final MapEntry(key: name, value: size) in _sizes.entries) {
    group(name, () {
      testWidgets('intro plays then calls onDone', (tester) async {
        _size(tester, size);
        var done = 0;
        await tester.pumpWidget(_host(_gate(() => done++)));
        expect(find.byType(IntroOverlay), findsOneWidget);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 2500));
        expect(done, 0);
        expect(find.byType(IntroOverlay), findsOneWidget);
        await tester.pump();
        await tester.pump();
        await tester.pump(IntroTimeline.total);
        expect(done, 1);
        expect(find.byType(IntroOverlay), findsNothing);
        expect(find.text('app'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('tap skips the intro', (tester) async {
        _size(tester, size);
        var done = 0;
        await tester.pumpWidget(_host(_gate(() => done++)));
        await tester.pump(const Duration(milliseconds: 800));
        await tester.tapAt(const Offset(40, 400));
        await tester.pump();
        await tester.pump(
          IntroTimeline.skipRun + const Duration(milliseconds: 50),
        );
        expect(done, 1);
        expect(find.byType(IntroOverlay), findsNothing);
      });

      testWidgets('skip pill and Escape skip the intro', (tester) async {
        _size(tester, size);
        var done = 0;
        await tester.pumpWidget(_host(_gate(() => done++)));
        await tester.pump(const Duration(milliseconds: 800));
        await tester.tap(find.text('Passer'));
        await tester.pump();
        await tester.pump(
          IntroTimeline.skipRun + const Duration(milliseconds: 50),
        );
        expect(done, 1);
        IntroGate.resetSession();
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(_host(_gate(() => done++)));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();
        await tester.pump(
          IntroTimeline.skipRun + const Duration(milliseconds: 50),
        );
        expect(done, 2);
      });

      testWidgets('reduced motion skips the intro entirely', (tester) async {
        _size(tester, size);
        var done = 0;
        await tester.pumpWidget(_host(_gate(() => done++), reduced: true));
        await tester.pump();
        expect(find.byType(IntroOverlay), findsNothing);
        expect(done, 1);
        expect(find.text('app'), findsOneWidget);
      });

      testWidgets('demo pauses and resumes on tap', (tester) async {
        _size(tester, size);
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(
          _host(
            const SizedBox(
              width: 220,
              height: 280,
              child: DemoPlayer(
                pauseLabel: 'Pause the animated demo',
                playLabel: 'Play',
                color: Colors.white,
                contrast: Colors.purple,
                mockup: true,
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 600));
        expect(tester.binding.transientCallbackCount, greaterThan(0));
        expect(
          find.bySemanticsLabel('Pause the animated demo'),
          findsOneWidget,
        );
        await tester.tap(find.byType(DemoPlayer));
        await tester.pump();
        expect(find.bySemanticsLabel('Play'), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.binding.transientCallbackCount, 0);
        await tester.tap(find.byType(DemoPlayer));
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          find.bySemanticsLabel('Pause the animated demo'),
          findsOneWidget,
        );
        expect(tester.binding.transientCallbackCount, greaterThan(0));
        semantics.dispose();
      });

      testWidgets('demo tiles fill their cells', (tester) async {
        _size(tester, size);
        await tester.pumpWidget(
          _host(
            const SizedBox(
              width: 300,
              height: 168,
              child: DemoPlayer(
                pauseLabel: 'Pause the animated demo',
                playLabel: 'Play',
                color: Colors.white,
                contrast: Colors.purple,
              ),
            ),
          ),
        );
        for (final type in [DemoDieTile, DemoScoreTile, DemoTimerTile]) {
          final box = tester.getSize(find.byType(type));
          expect(box.width, greaterThan(60));
          expect(box.height, greaterThan(40));
        }
      });

      testWidgets('demo is a static frame with reduced motion', (tester) async {
        _size(tester, size);
        await tester.pumpWidget(
          _host(
            const SizedBox(
              width: 220,
              height: 280,
              child: DemoPlayer(
                pauseLabel: 'Pause the animated demo',
                playLabel: 'Play',
                color: Colors.white,
                contrast: Colors.purple,
              ),
            ),
            reduced: true,
          ),
        );
        await tester.pump(const Duration(milliseconds: 600));
        expect(tester.binding.transientCallbackCount, 0);
        expect(tester.takeException(), isNull);
      });
    });
  }

  testWidgets('intro runs once per session', (tester) async {
    var done = 0;
    await tester.pumpWidget(_host(_gate(() => done++)));
    await tester.pump();
    await tester.pump();
    await tester.pump(IntroTimeline.total + const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_host(_gate(() => done++)));
    await tester.pump();
    expect(find.byType(IntroOverlay), findsNothing);
  });
}
