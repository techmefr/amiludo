import 'package:flutter/material.dart';
import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/technical/Locale/supported_languages.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/router.dart';
import 'package:amiludo/layers/functional/Account/presentation/cubit/account_cubit.dart';
import 'package:amiludo/layers/functional/Evenings/presentation/cubit/evenings_cubit.dart';
import 'package:amiludo/layers/functional/Lobby/presentation/cubit/lobby_cubit.dart';
import 'package:amiludo/layers/technical/Network/remote_config.dart';
import 'package:amiludo/layers/functional/Appearance/presentation/cubit/appearance_cubit.dart';
import 'package:amiludo/layers/functional/Friends/presentation/cubit/friends_cubit.dart';
import 'package:amiludo/layers/functional/Game/presentation/cubit/game_cubit.dart';
import 'package:amiludo/layers/functional/History/presentation/cubit/history_cubit.dart';
import 'package:amiludo/layers/functional/Library/presentation/cubit/library_cubit.dart';
import 'package:amiludo/layers/functional/Memories/presentation/cubit/memories_cubit.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/random_cubit.dart';
import 'package:amiludo/layers/functional/Sharing/presentation/cubit/sharing_cubit.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/templates_cubit.dart';
import 'package:amiludo/layers/functional/Timer/presentation/cubit/timer_cubit.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/cubit/workspace_cubit.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/cubit/workspace_state.dart';
import 'package:amiludo/layers/technical/About/app_info.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/layers/technical/Theme/deck_theme.dart';
import 'package:amiludo/layers/technical/Feedback/deck_haptics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RemoteConfig.start();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  registerFontLicenses();
  configureDependencies(StoreDatabase());
  runApp(const AmiludoApp());
}

List<BlocProvider> _providers() => [
  ..._tableProviders(),
  ..._collectionProviders(),
  ..._gatheringProviders(),
];

List<BlocProvider> _tableProviders() => [
  BlocProvider<WorkspaceCubit>(
    create: (_) =>
        WorkspaceCubit(getIt(), getIt(), getIt(), getIt(), getIt(), getIt())
          ..load(),
  ),
  BlocProvider<GameCubit>(
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
      getIt(),
      getIt(),
    ),
  ),
  BlocProvider<TimerCubit>(
    create: (_) =>
        TimerCubit(getIt(), getIt(), getIt(), getIt(), getIt(), getIt()),
  ),
  BlocProvider<AppearanceCubit>(
    create: (_) => AppearanceCubit(getIt(), getIt(), getIt(), getIt(), getIt()),
  ),
  BlocProvider<TemplatesCubit>(
    create: (_) => TemplatesCubit(getIt(), getIt(), getIt(), getIt()),
  ),
  BlocProvider<RandomCubit>(
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
      rememberTool: getIt(),
      reorderFavorites: getIt(),
    ),
  ),
];

List<BlocProvider> _collectionProviders() => [
  BlocProvider<LibraryCubit>(
    create: (_) => LibraryCubit(
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
    ),
  ),
  BlocProvider<FriendsCubit>(
    create: (_) => FriendsCubit(
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
    ),
  ),
  BlocProvider<MemoriesCubit>(
    create: (_) => MemoriesCubit(
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
  BlocProvider<SharingCubit>(
    create: (_) => SharingCubit(getIt(), getIt(), getIt(), getIt(), getIt()),
  ),
  BlocProvider<HistoryCubit>(
    create: (_) => HistoryCubit(
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
];

List<BlocProvider> _gatheringProviders() => [
  BlocProvider<LobbyCubit>(
    create: (_) => LobbyCubit(
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
  BlocProvider<AccountCubit>(
    create: (_) => AccountCubit(
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
      getIt(),
    ),
  ),
  BlocProvider<EveningsCubit>(
    create: (_) => EveningsCubit(
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
      getIt(),
    ),
  ),
];

class AmiludoApp extends StatelessWidget {
  const AmiludoApp({super.key});

  void _keepAwake(BuildContext context, WorkspaceState state) {
    final value = state.workspace;
    WakelockPlus.toggle(
      enable:
          value.appearance.keepAwake &&
          value.current != null &&
          value.current!.finishedAt == null,
    ).onError((Object e, StackTrace s) {});
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: _providers(),
    child: BlocListener<WorkspaceCubit, WorkspaceState>(
      listener: _keepAwake,
      child: const _AmiludoRouter(),
    ),
  );
}

class _AmiludoRouter extends StatelessWidget {
  const _AmiludoRouter();

  ThemeMode _mode(Appearance appearance) => switch (appearance.mode) {
    'system' => ThemeMode.system,
    'light' => ThemeMode.light,
    _ => ThemeMode.dark,
  };

  @override
  Widget build(BuildContext context) {
    final appearance = context.select<WorkspaceCubit, Appearance>(
      (cubit) => cubit.state.workspace.appearance,
    );
    DeckHaptics.enabled = appearance.haptics;
    return MaterialApp.router(
      title: 'amiLudo',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: appearance.language == autoLanguage
          ? null
          : Locale(appearance.language),
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: resolveLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      theme: deckTheme(appearance, Brightness.light),
      darkTheme: deckTheme(appearance, Brightness.dark),
      themeMode: _mode(appearance),
      themeAnimationDuration: appearance.motion
          ? const Duration(milliseconds: 180)
          : Duration.zero,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations:
              !appearance.motion || MediaQuery.of(context).disableAnimations,
        ),
        child: child!,
      ),
    );
  }
}
