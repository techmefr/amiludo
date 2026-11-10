import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/tool_catalog.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';

const auditSizes = [
  Size(360, 740),
  Size(412, 915),
  Size(768, 1024),
  Size(1024, 768),
  Size(1280, 720),
  Size(1920, 1080),
  Size(800, 600),
  Size(844, 390),
];

const auditScales = [1.0, 1.3];

const auditScreens = [
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
  '/build',
  '/chronicles',
  '/campaign',
  '/notebook',
  '/dice/designs',
  '/builder/new',
  '/library/tonight',
  '/marketplace',
  '/share',
  '/share/receive',
  '/lobby',
  '/join',
  '/admin',
  '/character-sheet',
  '/tools?category=chance',
  '/tools?category=match',
  '/tools?category=time',
  '/tools?category=story',
];

List<String> auditRoutes() => [
  ...auditScreens,
  for (final tool in toolDefinitions) '/tools/${tool.id}',
];

const minTarget = 44.0;

Future<List<String>> auditRoute(
  WidgetTester tester,
  Size size,
  Iterable<String> routes, {
  List<String> Function(String route, Size size)? extra,
}) async {
  final db = StoreDatabase.forTesting(NativeDatabase.memory());
  configureDependencies(db);
  addTearDown(getIt.reset);
  await tester.pumpWidget(const AmiludoApp());
  await tester.pumpAndSettle();
  final findings = <String>[];
  final previous = FlutterError.onError;
  var current = '';
  FlutterError.onError = (d) =>
      findings.add('$current: error ${'${d.exception}'.split('\n').first}');
  for (final route in routes) {
    current = route;
    router.go('/');
    await _settle(tester, <String>[], '/');
    router.go(route);
    await _settle(tester, findings, route);
    findings.addAll(inspectLayout(route, size));
    findings.addAll(extra?.call(route, size) ?? const []);
  }
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  FlutterError.onError = previous;
  await db.close();
  return findings;
}

Future<void> _settle(
  WidgetTester tester,
  List<String> findings,
  String route,
) async {
  try {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 4),
    );
  } catch (_) {
    if (route != '/marketplace') findings.add('$route: never settles');
  }
}

List<String> inspectLayout(String route, Size size) {
  final out = <String>[];
  final screen = Offset.zero & size;
  final small = <String>{};
  void visit(RenderObject node) {
    if (node is RenderBox && node.attached && node.hasSize) {
      final box = MatrixUtils.transformRect(
        node.getTransformTo(null),
        Offset.zero & node.size,
      );
      final onScreen = box.overlaps(screen);
      final text = node is RenderParagraph ? node.text.toPlainText() : '';
      if (onScreen && text.trim().isNotEmpty && !_scrollsSideways(node)) {
        if (box.left < -.5 || box.right > size.width + .5) {
          out.add(
            '$route: text outside viewport ${box.left.round()}..${box.right.round()} ${text.split('\n').first}',
          );
        }
      }
    }
    node.visitChildren(visit);
  }

  void tap(Element element) {
    final widget = element.widget;
    final isTap =
        widget is ButtonStyleButton ||
        widget is IconButton ||
        (widget is InkResponse && widget.onTap != null);
    final box = element.renderObject;
    if (isTap && box is RenderBox && box.attached && box.hasSize) {
      final r = box.localToGlobal(Offset.zero) & box.size;
      var padded = false;
      var depth = 0;
      element.visitAncestorElements((e) {
        final w = e.widget;
        padded =
            padded ||
            w is ButtonStyleButton ||
            w is IconButton ||
            w is RawChip ||
            w is ListTile ||
            w is SegmentedButton ||
            w is NavigationDestination;
        return !padded && ++depth < 30;
      });
      if (!padded &&
          r.overlaps(screen) &&
          r.shortestSide > 0 &&
          r.shortestSide < minTarget - 1 &&
          r.longestSide < 400 &&
          r.longestSide > 24) {
        final names = <String>[];
        element.visitAncestorElements((e) {
          names.add('${e.widget.runtimeType}');
          return names.length < 9;
        });
        small.add(
          '${names.join('<')} ${widget.runtimeType} ${r.width.round()}x${r.height.round()}@${r.left.round()},${r.top.round()}',
        );
      }
    }
    element.visitChildren(tap);
  }

  visit(WidgetsBinding.instance.renderViews.first);
  tap(WidgetsBinding.instance.rootElement!);
  for (final s in small) {
    out.add('$route: tap target $s');
  }
  return out;
}

bool _scrollsSideways(RenderObject node) {
  RenderObject? current = node.parent;
  while (current != null) {
    if (current is RenderAbstractViewport) return true;
    current = current.parent;
  }
  return false;
}
