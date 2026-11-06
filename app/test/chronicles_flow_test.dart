import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_gateways.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_run.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_use_cases.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/chronicles_view.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/chronicles_cubit.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Theme/deck_theme.dart';

import 'chronicles_fixtures.dart';

class MemoryRuns implements ChroniclesRunGateway {
  Map<String, dynamic>? value;

  @override
  Map<String, dynamic>? get stored => value;

  @override
  Future<void> saveRun(Map<String, Object?>? run) async {
    value = run == null
        ? null
        : jsonDecode(jsonEncode(run)) as Map<String, dynamic>;
  }
}

class SampleCatalog implements ChroniclesCatalogGateway {
  @override
  Future<ChroniclesData> load() async => sampleData();
}

ChroniclesCubit cubitFor(MemoryRuns runs, int seed) => ChroniclesCubit(
  LoadChroniclesUseCase(SampleCatalog(), runs),
  SaveChroniclesRunUseCase(runs),
  random: seeded(seed),
);

Widget host(ChroniclesCubit cubit) => BlocProvider.value(
  value: cubit,
  child: MaterialApp(
    theme: deckTheme(const Appearance(), Brightness.light),
    home: const Scaffold(body: SingleChildScrollView(child: ChroniclesView())),
  ),
);

bool has(String key) => find.byKey(ValueKey(key)).evaluate().isNotEmpty;

Future<void> tapKey(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  test('every action is saved and a new cubit resumes the same run', () async {
    final runs = MemoryRuns();
    final first = cubitFor(runs, 4);
    await first.load();
    expect(first.state.run, isNull);
    await first.start('fantasy');
    await first.openBooster('fer');
    await first.keep();
    expect(runs.value, isNotNull);
    final second = cubitFor(runs, 4);
    await second.load();
    expect(second.state.run!.toJson(), first.state.run!.toJson());
    await second.restart();
    expect(runs.value, isNull);
  });

  test('a refused card stays on the table with a refusal', () async {
    final runs = MemoryRuns();
    final cubit = cubitFor(runs, 9);
    await cubit.load();
    await cubit.start('fantasy');
    await cubit.openBooster('fer');
    var refused = false;
    for (var i = 0; i < 40 && cubit.state.run!.current != null; i++) {
      await cubit.keep();
      refused = refused || cubit.state.refusal != null;
      if (cubit.state.refusal != null) await cubit.pass();
    }
    expect(cubit.state.run!.kept, isNotEmpty);
    expect(refused || cubit.state.run!.phase == ChroniclesPhase.recap, isTrue);
  });

  for (final size in const [Size(390, 844), Size(1280, 720)]) {
    testWidgets('a whole game is playable at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final runs = MemoryRuns();
      final cubit = cubitFor(runs, 21);
      addTearDown(cubit.close);
      await cubit.load();
      await tester.pumpWidget(host(cubit));
      await tester.pumpAndSettle();
      await tapKey(tester, 'universe-fantasy');
      for (var i = 0; i < 600; i++) {
        if (find.text('Character sheet').evaluate().isNotEmpty) break;
        if (has('flip')) {
          await tapKey(tester, 'flip');
        } else if (has('keep')) {
          await tapKey(tester, 'keep');
          if (find.textContaining('conflicts').evaluate().isNotEmpty ||
              find.textContaining('No room').evaluate().isNotEmpty) {
            await tapKey(tester, 'pass');
          }
        } else if (has('continue')) {
          await tapKey(tester, 'continue');
        } else if (has('tear')) {
          await tapKey(tester, 'edition-fer');
          await tapKey(tester, 'tear');
        }
      }
      expect(find.text('Character sheet'), findsOneWidget);
      expect(has('copy-text') && has('copy-json') && has('share'), isTrue);
      expect(tester.takeException(), isNull);
      expect(runs.value!['phase'], 'done');
    });
  }
}
