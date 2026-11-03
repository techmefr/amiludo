import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_inputs.dart';

void main() {
  test('options split on commas and lines and drop blanks', () {
    expect(parseOptions(' a, b\n\nc ,, '), ['a', 'b', 'c']);
    expect(parseOptions('  '), isEmpty);
  });

  test('number bounds need two ordered integers', () {
    final bounds = NumberBounds.parse(' -3 ', '7');
    expect([bounds.minimum, bounds.maximum], [-3, 7]);
    for (final (low, high) in [
      ('a', '2'),
      ('1', ''),
      ('5', '4'),
      ('0', '2000000000'),
    ]) {
      expect(
        () => NumberBounds.parse(low, high),
        throwsA(RandomInputError.invalidBounds),
      );
    }
  });

  test('an empty bag is refused', () {
    expect(parseBag('Rouge, Rouge'), ['Rouge', 'Rouge']);
    expect(() => parseBag(' , '), throwsA(RandomInputError.emptyBag));
  });

  test('roles match the number of players', () {
    expect(parseRoles('Loup, Villageois', 2), ['Loup', 'Villageois']);
    expect(() => parseRoles('Loup', 2), throwsA(RandomInputError.roleCount));
    expect(() => parseRoles('', 0), throwsA(RandomInputError.roleCount));
    expect(starterRoles(3, 'Loup', 'Villageois'), [
      'Loup',
      'Villageois',
      'Villageois',
    ]);
  });

  test('wheel weights default to one and stay in range', () {
    final wheel = WheelOptions.parse('Camille:2, Alex');
    expect(wheel.labels, ['Camille', 'Alex']);
    expect(wheel.weights, [2, 1]);
    expect(
      () => WheelOptions.parse('Seul'),
      throwsA(RandomInputError.wheelSize),
    );
    expect(
      () => WheelOptions.parse(List.filled(51, 'x').join(',')),
      throwsA(RandomInputError.wheelSize),
    );
    for (final text in ['a:0, b', 'a:x, b', 'a:1:2, b', 'a:1000001, b']) {
      expect(
        () => WheelOptions.parse(text),
        throwsA(RandomInputError.wheelWeight),
      );
    }
  });
}
