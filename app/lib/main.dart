import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/router.dart';
import 'package:amiludo/layers/functional/Appearance/presentation/cubit/appearance_cubit.dart';
import 'package:amiludo/layers/functional/Game/presentation/cubit/game_cubit.dart';
import 'package:amiludo/layers/functional/History/presentation/cubit/history_cubit.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/random_cubit.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/templates_cubit.dart';
import 'package:amiludo/layers/functional/Timer/presentation/cubit/timer_cubit.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/cubit/workspace_cubit.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/cubit/workspace_state.dart';
import 'package:amiludo/layers/technical/About/app_info.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/layers/technical/Theme/deck_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  registerFontLicenses();
  configureDependencies(StoreDatabase());
  runApp(const AmiludoApp());
}

class AmiludoApp extends StatelessWidget {
  const AmiludoApp({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            WorkspaceCubit(getIt(), getIt(), getIt(), getIt(), getIt(), getIt())
              ..load(),
      ),
      BlocProvider(
        create: (_) => GameCubit(
          getIt(),
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
      ),
      BlocProvider(
        create: (_) =>
            TimerCubit(getIt(), getIt(), getIt(), getIt(), getIt(), getIt()),
      ),
      BlocProvider(
        create: (_) =>
            AppearanceCubit(getIt(), getIt(), getIt(), getIt(), getIt()),
      ),
      BlocProvider(
        create: (_) => TemplatesCubit(getIt(), getIt(), getIt(), getIt()),
      ),
      BlocProvider(
        create: (_) => RandomCubit(getIt(), getIt(), getIt(), getIt(), getIt()),
      ),
      BlocProvider(
        create: (_) => HistoryCubit(
          getIt(),
          getIt(),
          getIt(),
          getIt(),
          getIt(),
          getIt(),
          getIt(),
        ),
      ),
    ],
    child: BlocListener<WorkspaceCubit, WorkspaceState>(
      listener: (context, state) {
        final value = state.workspace;
        WakelockPlus.toggle(
          enable:
              value.appearance.keepAwake &&
              value.current != null &&
              value.current!.finishedAt == null,
        ).onError((Object e, StackTrace s) {});
      },
      child: Builder(
        builder: (context) {
          final appearance = context.select<WorkspaceCubit, Appearance>(
            (cubit) => cubit.state.workspace.appearance,
          );
          return MaterialApp.router(
            title: 'amiLudo',
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            locale: Locale(appearance.language),
            supportedLocales: const [Locale('fr'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: deckTheme(appearance, Brightness.light),
            darkTheme: deckTheme(appearance, Brightness.dark),
            themeMode: appearance.mode == 'system'
                ? ThemeMode.system
                : appearance.mode == 'light'
                ? ThemeMode.light
                : ThemeMode.dark,
            themeAnimationDuration: appearance.motion
                ? const Duration(milliseconds: 180)
                : Duration.zero,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                disableAnimations:
                    !appearance.motion ||
                    MediaQuery.of(context).disableAnimations,
              ),
              child: child!,
            ),
          );
        },
      ),
    ),
  );
}
