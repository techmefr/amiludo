import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/tool_catalog.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/app_shell.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/layers/functional/Random/presentation/time_tools_shell.dart';
import 'package:amiludo/router.dart';

void main() {
  for (final size in const [Size(390, 844), Size(844, 390), Size(1440, 1100)]) {
    testWidgets('every tool occupies the window and returns at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = StoreDatabase.forTesting(NativeDatabase.memory());
      configureDependencies(db);
      addTearDown(getIt.reset);
      await tester.pumpWidget(const AmiludoApp());
      await tester.pumpAndSettle();
      for (final tool in toolDefinitions) {
        router.go('/tools');
        await tester.pumpAndSettle();
        router.push('/tools/${tool.id}');
        await tester.pumpAndSettle();
        expect(find.byType(AppShell), findsNothing, reason: tool.id);
        expect(find.byType(BackButtonIcon), findsOneWidget, reason: tool.id);
        expect(find.byType(AppBar), findsNothing, reason: tool.id);
        final frame = timeToolIds.contains(tool.id) ? TimeToolsShell : FullPage;
        expect(tester.getSize(find.byType(frame)), size, reason: tool.id);
        expect(tester.takeException(), isNull, reason: tool.id);
        await tester.tap(find.byType(BackButtonIcon));
        await tester.pumpAndSettle();
        expect(find.byType(AppShell), findsOneWidget, reason: tool.id);
      }
      router.go('/timer');
      await tester.pumpAndSettle();
      expect(find.byType(AppShell), findsNothing);
      expect(find.byType(FullPage), findsOneWidget);
      await tester.tap(find.byType(BackButtonIcon));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/tools');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await db.close();
    });
  }
}
