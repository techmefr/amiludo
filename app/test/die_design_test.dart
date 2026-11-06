import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_bundle.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_face_ops.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_library.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_controls.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/pack_components.dart';

Uint8List png(int w, int h) {
  final data = ByteData(33);
  const sig = [137, 80, 78, 71, 13, 10, 26, 10];
  for (var i = 0; i < 8; i++) {
    data.setUint8(i, sig[i]);
  }
  data.setUint32(16, w);
  data.setUint32(20, h);
  return data.buffer.asUint8List();
}

DieDesign withImage(String id, String image) => DieDesign(
  id: id,
  name: 'Art',
  faces: [
    DieFaceContent(kind: DieFaceKind.image, value: image),
    const DieFaceContent(kind: DieFaceKind.icon, value: 'sword'),
  ],
);

void main() {
  group('shapes and sizes', () {
    test('solids keep their shape and the rest is generic', () {
      expect(DieShape.forSides(2), DieShape.coin);
      expect(DieShape.forSides(4), DieShape.d4);
      expect(DieShape.forSides(20), DieShape.d20);
      expect(DieShape.forSides(7), DieShape.generic);
      expect(DieShape.forSides(100), DieShape.generic);
    });

    for (final n in [2, 20, 100]) {
      test('a $n-face die round-trips through JSON', () {
        final d = DieDesign.standard('a', 'Die', n);
        final back = DieDesign.fromJson(
          Map<String, dynamic>.from(jsonDecode(jsonEncode(d.toJson())) as Map),
        );
        expect(back.sides, n);
        expect(back.toJson(), d.toJson());
        expect(back.numeric, isTrue);
      });
    }

    test('the tray custom die accepts 2 to 100 faces', () {
      final text = [for (var i = 0; i < 150; i++) '$i'].join(',');
      expect(parseFaces(text), hasLength(100));
      expect(parseFaces('a,b'), hasLength(2));
      expect(DiceSpec.custom(parseFaces(text), 1).sides, 100);
    });

    test('1 and 101 faces are rejected', () {
      for (final n in [1, 101]) {
        final json = {
          'id': 'a',
          'name': 'x',
          'faces': [
            for (var i = 0; i < n; i++) {'kind': 'text', 'value': '$i'},
          ],
        };
        expect(() => DieDesign.fromJson(json), throwsFormatException);
      }
    });

    test('resize clamps between 2 and 100 and keeps existing faces', () {
      final d = DieDesign.standard('a', 'Die', 6);
      expect(d.resized(500).sides, 100);
      expect(d.resized(0).sides, 2);
      expect(d.resized(8).faces.first, d.faces.first);
    });
  });

  group('face operations', () {
    final d = DieDesign.standard('a', 'Die', 10);

    test('number range, fill, duplicate, remove, move', () {
      expect(d.numbered(0, 9, start: 0).faces.first.value, '0');
      expect(d.numbered(0, 9, start: 0).faces.last.value, '9');
      const star = DieFaceContent(kind: DieFaceKind.icon, value: 'star');
      expect(d.filled(2, 4, star).faces.where((f) => f == star), hasLength(3));
      expect(d.duplicated(0).sides, 11);
      expect(d.removedFace(0).sides, 9);
      expect(d.moved(0, 9).faces.last.value, '1');
      expect(d.resized(2).removedFace(0).sides, 2);
      expect(d.resized(100).duplicated(0).sides, 100);
    });
  });

  group('library and sharing', () {
    test('merge keeps both with a new id or replaces on clash', () {
      final mine = DieLibrary([DieDesign.standard('a', 'Mine', 6)]);
      final theirs = [DieDesign.standard('a', 'Theirs', 6)];
      expect(mine.clashes(theirs), {'a'});
      final both = mine.merge(theirs, ClashPolicy.keepBoth, () => 'n');
      expect(both.designs.map((d) => d.name), ['Mine', 'Theirs']);
      expect(both.byId('n')!.name, 'Theirs');
      final replaced = mine.merge(theirs, ClashPolicy.replace, () => 'n');
      expect(replaced.designs.single.name, 'Theirs');
    });

    test('a bundle embeds images and survives a round trip', () {
      final bundle = DieBundle([withImage('a', 'img1')], {'img1': png(256, 256)});
      final back = DieBundle.decode(bundle.encode());
      expect(back.designs.single.toJson(), bundle.designs.single.toJson());
      expect(back.images['img1'], png(256, 256));
    });

    test('remapping gives images fresh ids', () {
      var n = 0;
      final bundle = DieBundle([withImage('a', 'img1')], {'img1': png(8, 8)});
      final fresh = bundle.remapped(() => 'x${n++}');
      expect(fresh.designs.single.faces.first.value, 'x0');
      expect(fresh.images.keys, ['x0']);
    });

    test('strict validation refuses unsafe files', () {
      final good = DieBundle([withImage('a', 'i')], {'i': png(10, 10)});
      Map<String, dynamic> decoded() =>
          Map<String, dynamic>.from(jsonDecode(good.encode()) as Map);
      expect(
        () => DieBundle.decode(jsonEncode({...decoded(), 'script': 'x'})),
        throwsFormatException,
      );
      expect(
        () => DieBundle.decode(jsonEncode({...decoded(), 'format': 'other'})),
        throwsFormatException,
      );
      expect(
        () => DieBundle.decode(
          DieBundle([withImage('a', 'i')], {'i': png(257, 10)}).encode(),
        ),
        throwsFormatException,
      );
      expect(
        () => DieBundle.decode(
          DieBundle([withImage('a', 'i')], {'i': Uint8List(40)}).encode(),
        ),
        throwsFormatException,
      );
      expect(
        () => DieBundle.decode('x' * (maxBundleChars + 1)),
        throwsFormatException,
      );
      final missing = decoded()..['images'] = <String, dynamic>{};
      expect(() => DieBundle.decode(jsonEncode(missing)), throwsFormatException);
    });
  });

  group('references', () {
    test('a plain tray die keeps its exact JSON', () {
      const json = {'sides': 6, 'color': 0xFF3D7BD9};
      expect(DiceSpec.fromJson(json).toJson(), json);
      const custom = {
        'sides': 2,
        'faces': ['a', 'b'],
        'color': 0xFF3D7BD9,
      };
      expect(DiceSpec.fromJson(custom).toJson(), custom);
    });

    test('a design die scores numeric faces and survives JSON', () {
      final d = DieDesign.standard('a', 'Zero to nine', 10).numbered(0, 9, start: 0);
      final spec = DiceSpec.fromDesign(d);
      expect(spec.scoreOf(1), 0);
      expect(spec.scoreOf(10), 9);
      final back = DiceSpec.fromJson(spec.toJson());
      expect(back.design!.id, 'a');
      expect(back.sides, 10);
      final art = DiceSpec.fromDesign(withImage('b', 'i'));
      expect(art.scoreOf(1), isNull);
      expect(art.faceContent(2).value, 'sword');
    });

    test('a broken design falls back to a plain die', () {
      final spec = DiceSpec.fromJson({'sides': 8, 'design': {'id': 1}});
      expect(spec.sides, 8);
      expect(spec.design, isNull);
    });

    test('a template die references a design and stays backward compatible', () {
      const legacy = {
        'name': 'd',
        'count': 1,
        'faces': [
          {'label': 'a', 'value': 1.0},
          {'label': 'b', 'value': 2.0},
        ],
      };
      expect(GameDie.fromJson(legacy).toJson(), legacy);
      final linked = GameDie.fromJson({...legacy, 'design': 'abc'});
      expect(linked.design, 'abc');
      expect(linked.toJson()['design'], 'abc');
      expect(
        () => GameDie.fromJson({...legacy, 'design': ''}),
        throwsFormatException,
      );
    });
  });
}
