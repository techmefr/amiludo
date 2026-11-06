import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a template without bricks still loads', () {
    final t = GameTemplate.fromJson({'id': 'a', 'name': 'A'});
    expect(t.bricks, isEmpty);
  });

  test('bricks survive a round trip', () {
    const t = GameTemplate(
      id: 'b',
      name: 'B',
      bricks: [Brick(id: '1', type: 'counter')],
    );
    final back = GameTemplate.fromJson(t.toJson());
    expect(back.bricks.single.type, 'counter');
  });
}
