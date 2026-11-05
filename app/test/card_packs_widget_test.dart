import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Random/presentation/card_face.dart';
import 'package:amiludo/layers/functional/Random/presentation/character_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/random_cubit.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/pack_catalog.dart';
import "package:amiludo/layers/technical/Appearance/appearance.dart";
import "package:amiludo/layers/technical/Storage/store_database.dart";
import "package:amiludo/layers/technical/Theme/deck_theme.dart";

const _viewports = {
  'laptop 1280x720': Size(1280, 720),
  'desktop 1920x1080': Size(1920, 1080),
  'phone 390x844': Size(390, 844),
};

Widget _tool(GameTemplate pack) => BlocProvider<RandomCubit>(
  create: (_) => RandomCubit(
    getIt(),
    getIt(),
    getIt(),
    getIt(),
    getIt(),
    getIt(),
    getIt(),
    getIt(),
    getIt(),
  ),
  child: MaterialApp(
    theme: deckTheme(const Appearance(), Brightness.light),
    home: Scaffold(
      body: SingleChildScrollView(child: CharacterTool(pack: pack)),
    ),
  ),
);

Future<void> _openAndKeep(WidgetTester tester, int keep) async {
  await tester.ensureVisible(find.textContaining('Open the pack'));
  await tester.tap(find.textContaining('Open the pack'));
  await tester.pump();
  await tester.ensureVisible(find.text('Reveal all'));
  await tester.tap(find.text('Reveal all'));
  await tester.pump();
  for (var i = 0; i < keep; i++) {
    final card = find.byType(CardFace).at(i);
    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pump();
  }
}

Future<void> _confirm(WidgetTester tester) async {
  final next = find.byType(FilledButton).last;
  await tester.ensureVisible(next);
  await tester.tap(next);
  await tester.pump();
}

void main() {
  final pack = PackCatalog.decode(
    File('assets/community/catalog.json').readAsStringSync(),
  ).firstWhere((p) => p.id == 'example-booster');

  for (final MapEntry(key: label, value: size) in _viewports.entries) {
    testWidgets('a character is built from packs on $label', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = StoreDatabase.forTesting(NativeDatabase.memory());
      configureDependencies(db);
      addTearDown(getIt.reset);
      await tester.pumpWidget(_tool(pack));
      await tester.tap(find.text('Generate my character'));
      await tester.pump();
      for (final category in pack.creation) {
        expect(find.textContaining('Open the pack'), findsOneWidget);
        await _openAndKeep(tester, category.keepMin);
        await _confirm(tester);
      }
      expect(find.text('Your character'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Test hero');
      await tester.ensureVisible(find.text('Save the sheet'));
      await tester.tap(find.text('Save the sheet'));
      await tester.pump();
      expect(find.text('Character saved'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await db.close();
    });
  }

  testWidgets('an unfinished creation is restored with the same offers', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(db);
    addTearDown(getIt.reset);
    await tester.pumpWidget(_tool(pack));
    await tester.tap(find.text('Generate my character'));
    await tester.pump();
    await _openAndKeep(tester, pack.creation.first.keepMin);
    await _confirm(tester);
    expect(find.textContaining('STEP 2 /'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_tool(pack));
    await tester.pump();
    expect(find.textContaining('STEP 2 /'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
