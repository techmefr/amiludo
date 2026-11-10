import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Random/presentation/sheet/sheet_page.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Theme/components/action_bar.dart';
import 'package:amiludo/layers/technical/Theme/deck_theme.dart';

import 'character_sheet_widget_test.dart' show cubit;

void main() {
  testWidgets('generation buttons live in the sticky action bar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c = cubit(5);
    await c.load();
    await tester.pumpWidget(
      BlocProvider.value(
        value: c,
        child: MaterialApp(
          theme: deckTheme(const Appearance(), Brightness.light),
          home: const SheetPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ActionBar), findsNothing);
    c.start(c.state.generator!.tables.universes.keys.first);
    await tester.pumpAndSettle();
    final bar = find.byType(ActionBar);
    expect(bar, findsOneWidget);
    expect(
      find.descendant(
        of: bar,
        matching: find.byKey(const ValueKey('sheet-generate-all')),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('sheet-generate-all')), findsOneWidget);
  });
}
