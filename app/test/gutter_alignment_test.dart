import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/technical/Theme/tokens/layout_tokens.dart';

import 'responsive_audit.dart';

const gutterSizes = [Size(375, 812), Size(768, 1024), Size(1280, 720)];

const titledRoutes = [
  '/character-sheet',
  '/',
  '/tools',
  '/library',
  '/friends',
  '/history',
  '/evenings',
  '/appearance',
  '/account',
];

double? leftOf(String key) {
  final finder = find.byKey(ValueKey(key));
  if (finder.evaluate().isEmpty) return null;
  return TestWidgetsFlutterBinding.instance.renderViews.isEmpty
      ? null
      : (finder.first.evaluate().first.renderObject! as RenderBox)
            .localToGlobal(Offset.zero)
            .dx;
}

void main() {
  test('gutters follow the breakpoint scale', () {
    expect(Gutters.forWidth(375), 16);
    expect(Gutters.forWidth(768), 24);
    expect(Gutters.forWidth(1280), 32);
    expect(Gutters.columnInset(1280, 760), 260);
    expect(Gutters.columnInset(375, 760), 16);
  });

  for (final size in gutterSizes) {
    testWidgets('title and content share a left edge at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final misaligned = <String>[];
      final seen = <String>{};
      final findings = await auditRoute(
        tester,
        size,
        auditScreens,
        extra: (route, size) {
          final title = leftOf('screen-title');
          final content = leftOf('screen-content');
          if (title == null || content == null) return const [];
          seen.add(route);
          if ((title - content).abs() > .5) {
            misaligned.add('$route title $title content $content');
          }
          return const [];
        },
      );
      expect(findings, isEmpty, reason: findings.join('\n'));
      expect(misaligned, isEmpty, reason: misaligned.join('\n'));
      expect(seen, containsAll(titledRoutes));
    }, timeout: const Timeout(Duration(minutes: 8)));
  }
}
