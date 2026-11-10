import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/technical/Sensors/accelerometer_feed.dart';
import 'package:amiludo/layers/technical/Sensors/foil_tilt.dart';
import 'package:amiludo/layers/technical/Theme/components/holo_foil.dart';

class _Feed implements AccelerometerFeed {
  final controller = StreamController<AccelSample>.broadcast();

  @override
  Stream<AccelSample> get samples => controller.stream;
}

void main() {
  test('tilt maps flat device to centre', () {
    expect(
      foilTiltFromSample(const AccelSample(0, 0, 9.8)),
      const Offset(.5, .5),
    );
  });

  test('tilt is clamped to the unit square', () {
    expect(
      foilTiltFromSample(const AccelSample(50, -50, 0)),
      const Offset(1, 1),
    );
    expect(foilTiltFromSample(const AccelSample(-50, 50, 0)), Offset.zero);
  });

  testWidgets('foil subscribes to feed and cancels on dispose', (tester) async {
    final feed = _Feed();
    await tester.pumpWidget(
      MaterialApp(
        home: HoloFoil(
          feed: feed,
          child: const SizedBox(width: 100, height: 100),
        ),
      ),
    );
    expect(feed.controller.hasListener, isTrue);
    feed.controller.add(const AccelSample(3, -2, 9));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    expect(feed.controller.hasListener, isFalse);
  });

  testWidgets('foil falls back to pointer without sensors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HoloFoil(
          feed: NoAccelerometerFeed(),
          child: SizedBox(width: 100, height: 100),
        ),
      ),
    );
    final g = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await g.addPointer(location: const Offset(10, 10));
    await g.moveTo(const Offset(60, 60));
    await tester.pump();
    expect(find.byType(HoloFoil), findsOneWidget);
  });
}
