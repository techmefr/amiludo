import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';

void main() {
  const a = Brick(id: 'a', type: 'counter', settings: {'start': 50});
  const b = Brick(id: 'b', type: 'hourglass');
  const c = Brick(id: 'c', type: 'dice');
  const base = Companion(id: 'x', name: 'Duel', bricks: [a, b, c]);

  test('round trip keeps bricks, owners and settings', () {
    final owned = base.replace(
      a.copyWith(ownerKind: BrickOwnerKind.player, ownerId: 'p1'),
    );
    final back = Companion.fromJson(owned.toJson());
    expect(back.bricks.map((e) => e.id), ['a', 'b', 'c']);
    expect(back.bricks.first.ownerKind, BrickOwnerKind.player);
    expect(back.bricks.first.ownerId, 'p1');
    expect(back.bricks.first.settings['start'], 50);
  });

  test('unknown fields and unknown brick types are preserved', () {
    final json = {
      'id': 'x',
      'name': 'Duel',
      'version': 1,
      'future': {'k': 1},
      'bricks': [
        {
          'id': 'z',
          'type': 'from-the-future',
          'settings': {'q': 2},
          'novel': true,
        },
      ],
    };
    final out = Companion.fromJson(json).toJson();
    expect(out['future'], {'k': 1});
    final brick = (out['bricks'] as List).single as Map;
    expect(brick['type'], 'from-the-future');
    expect(brick['novel'], true);
    expect(brick['settings'], {'q': 2});
  });

  test('a newer format version is flagged and kept', () {
    final newer = Companion.fromJson({
      'id': 'x',
      'name': 'n',
      'version': companionFormatVersion + 1,
      'bricks': <Object>[],
    });
    expect(newer.fromNewerVersion, isTrue);
    expect(newer.toJson()['version'], companionFormatVersion + 1);
  });

  test('add, remove, move and replace keep the others untouched', () {
    expect(base.remove('b').bricks.map((e) => e.id), ['a', 'c']);
    expect(base.move(0, 2).bricks.map((e) => e.id), ['b', 'c', 'a']);
    expect(base.add(const Brick(id: 'd', type: 'score')).bricks.length, 4);
    final changed = base.replace(b.copyWith(settings: {'seconds': 60}));
    expect(changed.bricks[1].settings['seconds'], 60);
    expect(changed.bricks[0].settings['start'], 50);
  });
}
