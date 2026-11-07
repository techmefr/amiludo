import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

int count(Pattern pattern) {
  var total = 0;
  for (final file
      in Directory('lib/layers/functional')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
    total += pattern.allMatches(file.readAsStringSync()).length;
  }
  return total;
}

void main() {
  test('spacing and radius scales only grow', () {
    final spaces = [
      Space.xs,
      Space.sm,
      Space.md,
      Space.lg,
      Space.xl,
      Space.xxl,
      Space.section,
    ];
    expect(spaces, [...spaces]..sort());
    final radii = [Radii.sm, Radii.md, Radii.lg, Radii.pill];
    expect(radii, [...radii]..sort());
  });

  test('motion stays under 350 ms and targets are at least 44', () {
    expect(Motion.slow.inMilliseconds, lessThanOrEqualTo(350));
    expect(Motion.fast < Motion.base && Motion.base < Motion.slow, isTrue);
    expect(Targets.minimum, greaterThanOrEqualTo(44));
  });

  testWidgets('motion is instant when the system reduces motion', (
    tester,
  ) async {
    late Duration reduced, normal;
    Widget host(bool disable) => MediaQuery(
      data: MediaQueryData(disableAnimations: disable),
      child: Builder(
        builder: (context) {
          final value = Motion.of(context, Motion.base);
          if (disable) {
            reduced = value;
          } else {
            normal = value;
          }
          return const SizedBox();
        },
      ),
    );
    await tester.pumpWidget(host(true));
    await tester.pumpWidget(host(false));
    expect(reduced, Duration.zero);
    expect(normal, Motion.base);
  });

  test('hard-coded styling in features never grows', () {
    expect(count('fontFamily:'), lessThanOrEqualTo(12));
    expect(count(RegExp(r'Colors\.[a-z]')), lessThanOrEqualTo(9));
    expect(count(RegExp(r'fontSize: \d')), lessThanOrEqualTo(5));
  });

  test('clean tokens sit inside the scales and stay accessible', () {
    expect(Radii.control, inInclusiveRange(Radii.sm, Radii.md));
    expect(Radii.group, inInclusiveRange(Radii.md, Radii.lg));
    expect(Hairline.width, lessThanOrEqualTo(1));
    expect(Hairline.barOpacity, inInclusiveRange(.6, .95));
    expect(Numerals.tabular, isNotEmpty);
    expect(Motion.spring, isNotNull);
  });
}
