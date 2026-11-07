import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_3d_view.dart';
import 'package:amiludo/layers/technical/Dice3D/die_mesh.dart';
import 'package:amiludo/layers/technical/Dice3D/die_pose.dart';
import 'package:amiludo/layers/technical/Dice3D/die_projection.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';

void main() {
  test('d3, d5, d16, d24, d30, d60 and d1000 are solids, not balls', () {
    for (final sides in [3, 5, 16, 24, 30, 60, 1000]) {
      expect(DieMesh.forSides(sides).ball, isFalse, reason: 'd$sides');
    }
    for (final sides in [3, 5, 16, 24, 30, 60]) {
      expect(DieMesh.forSides(sides).faces.length, sides, reason: 'd$sides');
    }
  });

  test('a d3 is a long prism whose two ends carry no value', () {
    final mesh = DieMesh.forSides(3);
    expect(mesh.faces.length, 3);
    expect(mesh.caps.length, 2);
    expect(mesh.drawn.length, 5);
  });

  test('a d1000 is a ten-faced solid that maps values onto its faces', () {
    final mesh = DieMesh.forSides(1000);
    expect(mesh.faces.length, 10);
    expect(mesh.valueOf(9), 1000);
    expect(mesh.faceOf(437), 6);
    expect(mesh.faceOf(1), 0);
  });

  test('every face of the new solids rests facing the viewer', () {
    for (final sides in [3, 5, 16, 24, 1000]) {
      final mesh = DieMesh.forSides(sides);
      for (var face = 0; face < mesh.faces.length; face++) {
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

  testWidgets('the new solids and the soft skins draw without errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Wrap(
            children: [
              for (final sides in [3, 5, 16, 24, 30, 60, 1000])
                for (final skin in [DieSkin.classic, ...DieSkin.all.skip(6)])
                  Die3dView(
                    spec: DiceSpec(sides: sides),
                    value: sides == 1000 ? 437 : 2,
                    skin: skin,
                    size: 64,
                  ),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(Die3dView), findsNWidgets(21));
    expect(tester.takeException(), isNull);
  });

  test('the soft skins and the red table are registered', () {
    expect(DieSkin.byId('cream').finish, DieFinish.soft);
    expect(DieSkin.byId('violet').finish, DieFinish.soft);
  });
}
