import 'package:flutter_test/flutter_test.dart';

import 'responsive_harness.dart';

const secondary = [
  '/build',
  '/chronicles',
  '/campaign',
  '/notebook',
  '/dice/designs',
  '/builder/new',
  '/library/tonight',
  '/tools?category=chance',
  '/tools?category=match',
  '/tools?category=time',
  '/tools?category=story',
];

void main() {
  for (final size in responsiveSizes) {
    for (final scale in responsiveScales) {
      testWidgets('secondary screens fit at $size x$scale', (tester) async {
        await expectRoutesFit(tester, size, scale, secondary);
      });
    }
  }
}
