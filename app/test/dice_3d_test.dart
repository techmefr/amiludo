import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_page.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_3d_view.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Dice3D/die_mesh.dart';
import 'package:amiludo/layers/technical/Dice3D/die_pips.dart';
import 'package:amiludo/layers/technical/Dice3D/die_pose.dart';
import 'package:amiludo/layers/technical/Dice3D/die_projection.dart';
import 'package:amiludo/layers/technical/Dice3D/vec3.dart';

Widget host(Widget child, {bool reduced = false}) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, app) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
    child: app!,
  ),
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: child,
    ),
  ),
);

void main() {
  test('every face count has one mesh face per value', () {
    for (final sides in [...List.generate(29, (i) => i + 2), 50, 100]) {
      expect(DieMesh.forSides(sides).faces.length, sides, reason: '$sides');
    }
  });

  test('standard solids have the expected face shapes', () {
    final corners = {4: 3, 6: 4, 8: 3, 10: 4, 12: 5, 20: 3};
    corners.forEach((sides, count) {
      final mesh = DieMesh.forSides(sides);
      expect(mesh.ball, isFalse);
      for (final face in mesh.faces) {
        expect(face.corners.length, count, reason: 'd$sides');
        for (final c in face.corners) {
          expect(c.length, lessThanOrEqualTo(1.0001));
          expect((c - face.center).dot(face.normal).abs(), lessThan(1e-6));
        }
      }
    });
    expect(DieMesh.forSides(7).ball, isTrue);
  });

  test('opposite faces of a d6 add up to seven', () {
    final faces = DieMesh.forSides(6).faces;
    for (var i = 0; i < 6; i++) {
      expect(faces[i].normal.dot(faces[5 - i].normal), closeTo(-1, 1e-9));
    }
  });

  test('every face rests facing the viewer and is the most visible one', () {
    for (final sides in [2, 3, 4, 5, 6, 7, 8, 10, 12, 16, 20, 30, 60]) {
      final mesh = DieMesh.forSides(sides);
      for (var face = 0; face < sides; face++) {
        final flat = DiePose.facing(mesh, face).apply(mesh.faces[face].normal);
        expect(flat.z, closeTo(-1, 1e-9), reason: 'd$sides face $face');
        final shown = DieProjection.faces(
          mesh,
          DiePose.resting(mesh, face),
          10,
        );
        expect(shown.last.index, face, reason: 'd$sides face $face');
      }
    }
  });

  test('a die with no tumble rests exactly on its resting pose', () {
    final mesh = DieMesh.forSides(20);
    final rest = DiePose.resting(mesh, 7);
    final still = DiePose.tumbling(mesh, 7, 0, 0);
    for (final v in [Vec3(1, 0, 0), Vec3(0, 1, 0), Vec3(0, 0, 1)]) {
      expect((rest.apply(v) - still.apply(v)).length, lessThan(1e-9));
    }
  });

  test('rotations stay orthonormal', () {
    final mesh = DieMesh.forSides(12);
    final m = DiePose.tumbling(mesh, 3, 0.4, -0.7);
    expect(m.r0.length, closeTo(1, 1e-9));
    expect(m.r1.length, closeTo(1, 1e-9));
    expect(m.r0.dot(m.r1), closeTo(0, 1e-9));
    expect(m.r0.cross(m.r1).dot(m.r2), closeTo(1, 1e-9));
  });

  test('the 3D preference is omitted by default and survives a round trip', () {
    expect(const Appearance().toJson().containsKey('dice3d'), isFalse);
    final on = const Appearance().copyWith(dice3d: true);
    expect(on.toJson()['dice3d'], isTrue);
    expect(Appearance.fromJson(on.toJson()).dice3d, isTrue);
    expect(Appearance.fromJson(const Appearance().toJson()).dice3d, isFalse);
  });

  testWidgets('a 3D die shows its landing face design', (tester) async {
    await tester.pumpWidget(
      host(const Die3dView(spec: DiceSpec(sides: 6), value: 5)),
    );
    expect(find.byType(DiePips), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('5')), findsWidgets);
    await tester.pumpWidget(
      host(const Die3dView(spec: DiceSpec(sides: 8), value: 5)),
    );
    expect(find.text('5'), findsWidgets);
    await tester.pumpWidget(
      host(
        Die3dView(spec: DiceSpec.custom(['a', 'b', 'c'], 0xFF336699), value: 2),
      ),
    );
    expect(find.text('b'), findsWidgets);
  });

  testWidgets('the tray throws 3D dice and toggles back to 2D', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final seen = <bool>[];
    await tester.pumpWidget(
      host(DiceTrayPage(seed: 5, solid: true, onSolidChanged: seen.add)),
    );
    await tester.tap(find.text('Throw'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 6));
    expect(find.byType(Die3dView), findsNWidgets(2));
    final total = tester
        .widgetList<Die3dView>(find.byType(Die3dView))
        .fold<int>(0, (sum, d) => sum + d.value);
    expect(find.textContaining('$total'), findsWidgets);
    await tester.tap(find.text('2D'));
    await tester.pump();
    expect(seen, [false]);
    expect(find.byType(Die3dView), findsNothing);
  });

  testWidgets('reduced motion lands 3D dice at once', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      host(const DiceTrayPage(seed: 2, solid: true), reduced: true),
    );
    await tester.tap(find.text('Throw'));
    await tester.pump();
    expect(find.byType(Die3dView), findsNWidgets(2));
    final rest = tester.getCenter(find.byType(Die3dView).first);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.getCenter(find.byType(Die3dView).first), rest);
    expect(tester.takeException(), isNull);
  });
}
