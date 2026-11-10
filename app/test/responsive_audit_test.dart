import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'responsive_audit.dart';

void main() {
  for (final size in auditSizes) {
    for (final scale in [...auditScales, if (size.shortestSide == 320) 2.0]) {
      testWidgets('audit $size x$scale', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final findings = await auditRoute(tester, size, auditRoutes());
        final dump = Platform.environment['AUDIT_DUMP'];
        if (dump != null) {
          File('$dump/${size.width.round()}x${size.height.round()}_$scale.txt')
              .writeAsStringSync(findings.join('\n'));
        }
        if (dump != null) return;
        expect(findings, isEmpty, reason: findings.join('\n'));
      }, timeout: const Timeout(Duration(minutes: 8)));
    }
  }
}
