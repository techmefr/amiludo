import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/tool_catalog.dart';
import 'responsive_harness.dart';

const screens = [
  '/',
  '/game',
  '/tools',
  '/templates',
  '/library',
  '/friends',
  '/evenings',
  '/history',
  '/appearance',
  '/account',
];

void main() {
  for (final size in responsiveSizes) {
    for (final scale in responsiveScales) {
      testWidgets('main screens fit at $size x$scale', (tester) async {
        await expectRoutesFit(tester, size, scale, screens);
      });
      testWidgets('every registry tool fits at $size x$scale', (tester) async {
        await expectRoutesFit(tester, size, scale, [
          for (final tool in toolDefinitions) '/tools/${tool.id}',
        ]);
      });
    }
  }
}
