import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/World/domain/entities/map_element.dart';
import 'package:amiludo/layers/functional/World/domain/entities/map_pin.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_atlas.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_map.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_map_fog.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_map_pins.dart';
import 'package:amiludo/layers/functional/World/presentation/world_tool.dart';

MapPin pin(String id, double x, {bool secret = false}) => MapPin(
  id: id,
  kind: PinKind.place,
  point: WorldPoint(x, 0),
  title: 'Pin $id',
  secret: secret,
);

Widget host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SizedBox(height: 600, child: child)),
);

void main() {
  test('a reveal is added, then removed by revealing the same spot', () {
    var map = WorldMap.create('Town', ScaleLevel.city);
    final id = map.floors.single.id;
    map = map.toggleReveal(id, const WorldPoint(0, 0));
    expect(map.floors.single.reveals.length, 1);
    expect(map.isRevealed(id, const WorldPoint(revealRadius - 1, 0)), isTrue);
    expect(map.isRevealed(id, const WorldPoint(revealRadius + 1, 0)), isFalse);
    map = map.toggleReveal(id, const WorldPoint(10, 0));
    expect(map.floors.single.reveals, isEmpty);
  });

  test('players never see secret pins and see only revealed ones in fog', () {
    var map = WorldMap.create('Town', ScaleLevel.city);
    final id = map.floors.single.id;
    map = map
        .addPin(id, pin('a', 0))
        .addPin(id, pin('b', 0, secret: true))
        .addPin(id, pin('c', 1000));
    expect(map.visiblePins(id, player: false).length, 3);
    expect(map.visiblePins(id, player: true).map((p) => p.id), ['a', 'c']);
    map = map.copyWith(fog: true).toggleReveal(id, const WorldPoint(0, 0));
    expect(map.visiblePins(id, player: true).map((p) => p.id), ['a']);
    expect(map.visiblePins(id, player: false).length, 3);
  });

  test('fog, reveals and secrets survive a json round trip', () {
    var map = WorldMap.create('Town', ScaleLevel.city);
    final id = map.floors.single.id;
    map = map
        .addPin(id, pin('a', 0, secret: true))
        .copyWith(fog: true)
        .toggleReveal(id, const WorldPoint(5, 5));
    final text = WorldAtlas(maps: [map]).export();
    final back = const WorldAtlas().import(text)!.merged.maps.single;
    expect(back.fog, isTrue);
    expect(back.floors.single.reveals.single.x, 5);
    expect(back.floors.single.pins.single.secret, isTrue);
  });

  testWidgets('the player view hides secret pins and the toolbar', (
    tester,
  ) async {
    var map = WorldMap.create('Town', ScaleLevel.city);
    final id = map.floors.single.id;
    map = map.addPin(id, pin('a', 0)).addPin(id, pin('b', 80, secret: true));
    await tester.pumpWidget(host(WorldTool(initial: WorldAtlas(maps: [map]))));
    expect(find.text('Pin a'), findsOneWidget);
    expect(find.text('Pin b'), findsOneWidget);
    await tester.tap(find.byTooltip('Map options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Player view'));
    await tester.pumpAndSettle();
    expect(find.text('Pin a'), findsOneWidget);
    expect(find.text('Pin b'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, 'Reveal'), findsNothing);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });
}
