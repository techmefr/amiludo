import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/entities/card_pack_session.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/gateways/card_pack_gateway.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/use_cases/card_pack_use_cases.dart';
import 'package:amiludo/layers/functional/CardPacks/presentation/card_packs_page.dart';
import 'package:amiludo/layers/functional/CardPacks/presentation/cubit/card_pack_cubit.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/technical/Theme/components/pack/pack_stage.dart';

class MemoryGateway implements CardPackGateway {
  CardPackSession? stored;

  @override
  CardPackSession? get current => stored;

  @override
  Stream<CardPackSession?> get changes => const Stream.empty();

  @override
  Future<void> save(CardPackSession? session) async => stored = session;
}

CreationCategory category(String name) => CreationCategory(
  name: name,
  draw: 4,
  cards: [
    for (var i = 0; i < 8; i++)
      CharacterCard(name: '$name $i', description: 'About $i'),
  ],
);

final template = GameTemplate(
  id: 't',
  name: 'Demo',
  creation: [category('Origin'), category('Class')],
);

Future<MemoryGateway> pump(
  WidgetTester tester,
  Size size, {
  bool reduce = true,
  List<GameCharacter>? saved,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final memory = MemoryGateway();
  final cubit = CardPackCubit(
    ReadCardPackSessionUseCase(memory),
    SaveCardPackSessionUseCase(memory),
  );
  addTearDown(cubit.close);
  if (reduce) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider.value(
        value: cubit,
        child: CardPacksPage(
          templates: [template],
          onSave: saved == null ? null : (c) async => saved.add(c),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return memory;
}

void main() {
  for (final size in const [
    Size(375, 812),
    Size(768, 1024),
    Size(1280, 720),
    Size(812, 375),
  ]) {
    testWidgets('setup, packs, keep and sheet fit at $size', (tester) async {
      final saved = <GameCharacter>[];
      final memory = await pump(tester, size, saved: saved);
      await tester.scrollUntilVisible(
        find.text('Start the session'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Start the session'));
      await tester.pumpAndSettle();
      expect(memory.stored, isNotNull);
      expect(find.text('Pass the phone to Player 1'), findsOneWidget);

      for (final name in ['Origin', 'Class']) {
        await tester.ensureVisible(find.text('Open the $name pack').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Open the $name pack').first);
        await tester.pumpAndSettle();
      }
      expect(
        find.textContaining('Common').evaluate().isNotEmpty ||
            find.textContaining('Rare').evaluate().isNotEmpty ||
            find.textContaining('Holo').evaluate().isNotEmpty ||
            find.textContaining('Ultra').evaluate().isNotEmpty,
        isTrue,
      );

      final validate = find.widgetWithText(FilledButton, 'Validate my cards');
      await tester.scrollUntilVisible(
        validate,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.widget<FilledButton>(validate).onPressed, isNull);
      expect(find.text('2 more to keep'), findsOneWidget);

      final session = memory.stored!;
      final player = session.players.first;
      for (var p = 0; p < player.packs.length; p++) {
        final label = player.packs[p].cards.first.card.name;
        final card = find.bySemanticsLabel(RegExp('$label\\.'));
        await tester.scrollUntilVisible(
          card.first,
          -200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(card.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }
      expect(memory.stored!.players.first.kept.length, 2);
      await tester.scrollUntilVisible(
        validate,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.getSize(validate).height, greaterThanOrEqualTo(44));
      await tester.tap(validate);
      await tester.pumpAndSettle();
      expect(memory.stored!.players.first.validated, isTrue);
      expect(find.text("Player 1's character"), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Save to my characters'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Save to my characters'));
      await tester.pumpAndSettle();
      expect(saved.single.choices.keys, ['Origin', 'Class']);
      expect(saved.single.choices['Origin']!.length, 1);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the board hides picks until everyone opened in hidden mode', (
    tester,
  ) async {
    await pump(tester, const Size(768, 1024));
    await tester.scrollUntilVisible(
      find.text('Live reveal on the board'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Live reveal on the board'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Start the session'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Start the session'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Board'));
    await tester.pumpAndSettle();
    expect(
      find.text('Hidden until everyone has opened their packs'),
      findsOneWidget,
    );
    expect(find.text('0 / 2 packs opened'), findsNWidgets(2));
  });

  testWidgets('an invalid rule set is refused with the reason', (tester) async {
    final memory = await pump(tester, const Size(768, 1024));
    for (var i = 0; i < 8; i++) {
      await tester.scrollUntilVisible(
        find.byTooltip(RegExp(r'^Cards per pack: \d+ \+$')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byTooltip(RegExp(r'^Cards per pack: \d+ \+$')));
      await tester.pumpAndSettle();
    }
    await tester.scrollUntilVisible(
      find.text('Start the session'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Start the session'));
    await tester.pumpAndSettle();
    expect(memory.stored, isNull);
    expect(
      find.text('A deck has too few cards for these packs.'),
      findsOneWidget,
    );
  });

  testWidgets('animations play the pack opening when motion is allowed', (
    tester,
  ) async {
    await pump(tester, const Size(768, 1024), reduce: false);
    await tester.scrollUntilVisible(
      find.text('Start the session'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Start the session'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Open the Origin pack').first);
    await tester.pump(const Duration(milliseconds: 4000));
    expect(find.byType(PackStage), findsOneWidget);
    unawaited(Future<void>.value());
  });
}
