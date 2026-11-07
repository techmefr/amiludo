import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/character_sheet.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_fields.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_gateways.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_tables.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_use_cases.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/sheet_cubit.dart';
import 'package:amiludo/layers/functional/Random/presentation/sheet/sheet_page.dart';
import 'package:amiludo/layers/functional/Random/presentation/sheet/sheet_summary_card.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Theme/deck_theme.dart';

class _Tables implements SheetTablesGateway {
  @override
  Future<SheetTables> load() async => SheetTables.fromJson(
    jsonDecode(
      File('assets/chronicles/character-sheet-data.json').readAsStringSync(),
    ) as Map<String, dynamic>,
  );
}

SheetCubit cubit(int seed) => SheetCubit(
  LoadSheetGeneratorUseCase(_Tables()),
  random: RandomTools(random: Random(seed)),
);

Widget host(SheetCubit cubit, {Future<void> Function(GameCharacter)? onSave}) =>
    BlocProvider.value(
      value: cubit,
      child: MaterialApp(
        theme: deckTheme(const Appearance(), Brightness.light),
        home: Scaffold(
          body: SingleChildScrollView(child: SheetView(onSave: onSave)),
        ),
      ),
    );

Future<void> tapKey(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  for (final size in const [Size(390, 844), Size(1280, 720)]) {
    testWidgets('the sheet is editable step by step at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = cubit(5);
      addTearDown(c.close);
      await c.load();
      await tester.pumpWidget(host(c));
      await tester.pumpAndSettle();
      await tapKey(tester, 'sheet-universe-scifi');
      expect(find.text('Step 1 of 5'), findsWidgets);
      await tapKey(tester, 'sheet-generate-step');
      expect(c.state.sheet!.stepComplete(1), isTrue);
      expect(c.state.sheet!.stepComplete(2), isFalse);
      await tapKey(tester, 'sheet-next');
      expect(c.state.step, 2);
      await tapKey(tester, 'sheet-generate-all');
      expect(c.state.sheet!.completedSteps, SheetSpec.stepCount);
      expect(c.state.step, 1);
      await tapKey(tester, 'sheet-step-3');
      expect(find.byKey(const ValueKey('sheet-row-qualities')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('lock, reroll, edit and read at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = cubit(8);
      addTearDown(c.close);
      await c.load(universe: 'fantasy');
      await tester.pumpWidget(host(c));
      await tester.pumpAndSettle();
      await tapKey(tester, 'sheet-generate-all');
      await tapKey(tester, 'sheet-lock-job');
      final job = c.state.sheet!.first('job');
      expect(c.state.sheet!.isLocked('job'), isTrue);
      await tapKey(tester, 'sheet-generate-step');
      expect(c.state.sheet!.first('job'), job);
      await tapKey(tester, 'sheet-edit-nickname');
      await tester.enterText(
        find.byKey(const ValueKey('sheet-edit-input')),
        'Le Tisseur',
      );
      await tapKey(tester, 'sheet-edit-save');
      expect(c.state.sheet!.first('nickname'), 'Le Tisseur');
      await tapKey(tester, 'sheet-step-3');
      await tapKey(tester, 'sheet-edit-qualities');
      await tester.enterText(
        find.byKey(const ValueKey('sheet-edit-input')),
        'Vif',
      );
      await tapKey(tester, 'sheet-edit-save');
      expect(find.text('5 to 5 values expected'), findsOneWidget);
      c.setReading(true);
      await tester.pumpAndSettle();
      expect(find.textContaining('Le Tisseur'), findsWidgets);
      expect(find.byKey(const ValueKey('sheet-copy-json')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('saving stores the sheet with the character', (tester) async {
    final c = cubit(2);
    addTearDown(c.close);
    await c.load(universe: 'gothique');
    GameCharacter? saved;
    await tester.pumpWidget(host(c, onSave: (v) async => saved = v));
    await tester.pumpAndSettle();
    await tapKey(tester, 'sheet-generate-all');
    await tapKey(tester, 'sheet-save');
    expect(saved!.name, c.state.sheet!.first('name'));
    expect(saved!.sheet, c.state.sheet!.toJson());
  });

  testWidgets('the compact card summarises the sheet', (tester) async {
    final sheet = CharacterSheet(
      universe: 'fantasy',
      values: const {
        'age': ['34'],
        'job': ['Forgeron'],
        'qualities': ['Loyal', 'Calme'],
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SheetSummaryCard(sheet: sheet)),
      ),
    );
    expect(find.text('34 · Forgeron'), findsOneWidget);
    expect(find.text('Loyal · Calme'), findsOneWidget);
  });

  testWidgets('editions, resume callback and avatar hook', (tester) async {
    final changes = <CharacterSheet>[];
    final c = SheetCubit(
      LoadSheetGeneratorUseCase(_Tables()),
      random: RandomTools(random: Random(3)),
      onChanged: changes.add,
    );
    addTearDown(c.close);
    await c.load(universe: 'cyberpunk');
    Map<String, Object?>? given;
    await tester.pumpWidget(
      BlocProvider.value(
        value: c,
        child: MaterialApp(
          theme: deckTheme(const Appearance(), Brightness.light),
          home: Scaffold(
            body: SingleChildScrollView(
              child: SheetView(
                avatarEditor: (context, look, current) async {
                  given = {'tints': look.tints};
                  return {
                    'base': {'item': 'base.arms-1'},
                  };
                },
                avatarPreview: (avatar) =>
                    const SizedBox(key: ValueKey('preview')),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tapKey(tester, 'sheet-edition-esprit');
    expect(c.state.sheet!.edition, 'esprit');
    await tapKey(tester, 'sheet-generate-all');
    expect(changes, isNotEmpty);
    expect(changes.last.completedSteps, SheetSpec.stepCount);
    await tapKey(tester, 'sheet-avatar');
    expect(given, isNotNull);
    expect(c.state.sheet!.avatar, isNotNull);
    c.setReading(true);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('preview')), findsOneWidget);
  });
}
