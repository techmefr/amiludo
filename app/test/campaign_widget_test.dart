import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_catalog.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/campaign_screen.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/cubit/campaign_cubit.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/mission_screen.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Theme/deck_theme.dart';

import 'campaign_model_test.dart';

final fakeActions = <MissionAction, WidgetBuilder>{
  for (final action in MissionAction.values)
    action: (context) => Text('action-${action.name}'),
};

Widget app(MemoryCampaign gateway, {String start = '/'}) {
  final cubit = cubitOn(gateway);
  Widget scoped(Widget child) =>
      BlocProvider<CampaignCubit>.value(value: cubit, child: child);
  final router = GoRouter(
    initialLocation: start,
    routes: [
      GoRoute(path: '/', builder: (c, s) => scoped(const CampaignScreen())),
      GoRoute(
        path: '/campaign',
        builder: (c, s) => scoped(const CampaignScreen()),
      ),
      GoRoute(
        path: '/campaign/:id',
        builder: (c, s) => scoped(
          MissionScreen(
            mission: campaignMissions.firstWhere(
              (m) => m.id == s.pathParameters['id'],
            ),
            actions: fakeActions,
          ),
        ),
      ),
    ],
  );
  return MaterialApp.router(
    theme: deckTheme(const Appearance(), Brightness.light),
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  );
}

void main() {
  for (final size in const [Size(390, 844), Size(1280, 720)]) {
    testWidgets('missions list shows progress and locks at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(app(MemoryCampaign()));
      await tester.pumpAndSettle();
      expect(find.text('Role-playing initiation'), findsWidgets);
      expect(find.text('0 of ${campaignMissions.length} missions'), findsOneWidget);
      expect(find.text('The door that sticks'), findsOneWidget);
      expect(
        find.text('Finish the previous mission to unlock this one.'),
        findsWidgets,
      );
      expect(
        find.text('Complete a mission to earn your first badge.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a mission shows its story, action and rewards a badge at '
        '$size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final gateway = MemoryCampaign();
      await tester.pumpWidget(app(gateway, start: '/campaign/first-roll'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Night falls.'), findsOneWidget);
      expect(find.text('action-dice'), findsOneWidget);
      await tester.tap(find.text('Complete the mission'));
      await tester.pumpAndSettle();
      expect(gateway.current.isDone('first-roll'), isTrue);
      expect(find.text('Badge earned'), findsOneWidget);
      expect(find.text('Gate opener'), findsOneWidget);
      expect(find.text('Next mission'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the choice mission needs a choice before completing at '
        '$size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final gateway = MemoryCampaign();
      for (final mission in campaignMissions.take(4)) {
        await gateway.save(gateway.current.withCompleted(mission.id));
      }
      await tester.pumpWidget(app(gateway, start: '/campaign/crossroads'));
      await tester.pumpAndSettle();
      Finder complete() => find.widgetWithText(FilledButton, 'Complete the mission');
      await tester.ensureVisible(complete());
      await tester.pump();
      expect(tester.widget<FilledButton>(complete()).onPressed, isNull);
      await tester.tap(find.text('Go down to the cellar'));
      await tester.pump();
      expect(find.textContaining('forgotten key'), findsOneWidget);
      await tester.ensureVisible(complete());
      await tester.pump();
      await tester.tap(complete());
      await tester.pumpAndSettle();
      expect(gateway.current.choices['crossroads'], 1);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a locked mission shows the unlock hint instead of its action', (
    tester,
  ) async {
    await tester.pumpWidget(app(MemoryCampaign(), start: '/campaign/final-scene'));
    await tester.pumpAndSettle();
    expect(find.text('action-hourglass'), findsNothing);
    expect(
      find.text('Finish the previous mission to unlock this one.'),
      findsOneWidget,
    );
  });
}
