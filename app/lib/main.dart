import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'layers/technical/Appearance/appearance.dart';
import 'layers/technical/About/app_info.dart';
import 'layers/technical/Theme/deck_theme.dart';
import 'layers/technical/Theme/deck_widgets.dart';
import 'layers/functional/Workspace/workspace_controller.dart';
import 'layers/functional/Workspace/presentation/home_screen.dart';
import 'layers/functional/Game/presentation/game_screen.dart';
import 'layers/functional/Random/presentation/tools_screen.dart';
import 'layers/functional/Random/presentation/tool_page.dart';
import 'layers/functional/Templates/presentation/pack_builder.dart';
import 'layers/functional/Templates/presentation/pack_detail.dart';
import 'layers/functional/Templates/presentation/marketplace_screen.dart';
import 'layers/functional/Templates/domain/game_template.dart';
import 'layers/functional/Game/presentation/score_sheet.dart';
import 'layers/technical/Theme/full_page.dart';
import 'layers/functional/Templates/presentation/templates_screen.dart';
import 'layers/functional/History/presentation/history_screen.dart';
import 'layers/functional/Appearance/presentation/appearance_screen.dart';
import 'layers/functional/Timer/presentation/timer_panel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  registerFontLicenses();
  runApp(const ProviderScope(child: CompanionApp()));
}

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/tools/:id',
      builder: (context, state) => ToolPage(
        id: state.pathParameters['id']!,
        packId: state.uri.queryParameters['pack'],
        snapshot: state.uri.queryParameters['session'] == '1',
      ),
    ),
    GoRoute(
      path: '/builder/new',
      builder: (context, state) => const PackBuilder(),
    ),
    GoRoute(
      path: '/builder/:id',
      builder: (context, state) =>
          BuilderEntry(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/pack/:id',
      builder: (context, state) => PackDetail(
        id: state.pathParameters['id']!,
        snapshot: state.uri.queryParameters['session'] == '1',
      ),
    ),
    GoRoute(
      path: '/marketplace',
      builder: (context, state) => const MarketplaceScreen(),
    ),
    GoRoute(
      path: '/score/:player',
      builder: (context, state) =>
          ScoreSheet(playerId: state.pathParameters['player']!),
    ),
    for (final path in [
      '/',
      '/game',
      '/tools',
      '/templates',
      '/history',
      '/appearance',
      '/timer',
    ])
      GoRoute(
        path: path,
        builder: (context, state) => AppShell(
          path: state.uri.path,
          tool: state.uri.queryParameters['tool'],
        ),
      ),
  ],
);

class CompanionApp extends ConsumerWidget {
  const CompanionApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(workspaceProvider),
        appearance = data.value?.appearance ?? const Appearance();
    ref.listen(workspaceProvider, (_, next) {
      if (next.hasValue) {
        final value = next.requireValue;
        WakelockPlus.toggle(
          enable:
              value.appearance.keepAwake &&
              value.current != null &&
              value.current!.finishedAt == null,
        ).onError((Object e, StackTrace s) {});
      }
    });
    return MaterialApp.router(
      title: 'Amiludo',
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
              !appearance.motion || MediaQuery.of(context).disableAnimations,
        ),
        child: child!,
      ),
    );
  }
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.path, this.tool});
  final String path;
  final String? tool;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(workspaceProvider),
        theme = Theme.of(context),
        saveError = ref.watch(saveErrorProvider);
    final items = [
      ('/', Icons.home_outlined, tr(context, 'Accueil', 'Home')),
      ('/game', Icons.dashboard_outlined, tr(context, 'Ma partie', 'My game')),
      ('/tools', Icons.casino_outlined, tr(context, 'Outils', 'Tools')),
      (
        '/templates',
        Icons.view_module_outlined,
        tr(context, 'Modèles', 'Templates'),
      ),
      ('/history', Icons.history, tr(context, 'Historique', 'History')),
      ('/appearance', Icons.tune, tr(context, 'Apparence', 'Style')),
    ];
    final index = path == '/timer' ? 2 : items.indexWhere((i) => i.$1 == path);
    final desktop = MediaQuery.sizeOf(context).width >= 1000;
    final page = data.when(
      loading: () => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              tr(context, 'Ouverture de votre table…', 'Opening your table…'),
            ),
          ],
        ),
      ),
      error: (error, stack) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: EmptyPanel(
              title: tr(
                context,
                'La bibliothèque n’a pas pu être ouverte',
                'Could not open your library',
              ),
              message: tr(
                context,
                'Vos données ne sont pas écrasées. Vérifiez que ce navigateur autorise le stockage local et réessayez.',
                'Your data has not been overwritten. Check browser storage permissions and retry.',
              ),
              action: FilledButton(
                onPressed: () => ref.invalidate(workspaceProvider),
                child: Text(tr(context, 'Réessayer', 'Retry')),
              ),
            ),
          ),
        ),
      ),
      data: (value) {
        final screen = switch (path) {
          '/game' => const GameScreen(),
          '/timer' => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeckHeading(
                eyebrow: 'TEMPO / TIMER',
                title: tr(context, 'Un temps pour jouer', 'Time to play'),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: const TimerPanel(),
              ),
            ],
          ),
          '/tools' => ToolsScreen(key: ValueKey(tool), initialTool: tool),
          '/templates' => const TemplatesScreen(),
          '/history' => const HistoryScreen(),
          '/appearance' => const AppearanceScreen(),
          _ => const HomeScreen(),
        };
        return SingleChildScrollView(
          key: PageStorageKey(path),
          padding: EdgeInsets.fromLTRB(
            desktop ? 48 : 20,
            desktop ? 40 : 28,
            desktop ? 48 : 20,
            48,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1320),
              child: screen,
            ),
          ),
        );
      },
    );
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (desktop)
              Container(
                width: 240,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: theme.colorScheme.outline),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amiludo',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.brightness == Brightness.dark
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toutes vos parties',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontFamily: 'NunitoSans',
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 48),
                    for (final (route, icon, label) in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          selected: path == route,
                          selectedColor: theme.brightness == Brightness.dark
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                          selectedTileColor:
                              theme.colorScheme.surfaceContainerHighest,
                          leading: DeckIcon(icon, size: 20),
                          title: Text(
                            label,
                            style: const TextStyle(fontSize: 13),
                          ),
                          onTap: () => context.go(route),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      tr(
                        context,
                        '● Données sur cet appareil',
                        '● Data on this device',
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tr(
                        context,
                        'Amiludo · Alpha\nSans compte. Sans publicité.',
                        'Amiludo · Alpha\nNo account. No ads.',
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: desktop ? 80 : 64,
                    padding: EdgeInsets.symmetric(
                      horizontal: desktop ? 48 : 20,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: theme.colorScheme.outline),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (!desktop)
                          Text(
                            '◈',
                            style: TextStyle(
                              fontSize: 28,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        if (!desktop) const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Amiludo · ${items[index < 0 ? 0 : index].$3}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'NunitoSans',
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (desktop)
                          Text(
                            'Alpha $appVersion',
                            style: theme.textTheme.labelSmall,
                          ),
                        IconButton(
                          tooltip: tr(
                            context,
                            'À propos et retours',
                            'About and feedback',
                          ),
                          onPressed: () => showProjectInfo(context),
                          icon: const DeckIcon(Icons.info_outline, size: 20),
                        ),
                        IconButton(
                          tooltip: tr(context, 'Historique', 'History'),
                          onPressed: () => context.go('/history'),
                          icon: const DeckIcon(Icons.history, size: 20),
                        ),
                        IconButton(
                          tooltip: tr(
                            context,
                            'Changer la lumière',
                            'Toggle light',
                          ),
                          onPressed: data.hasValue
                              ? () => ref
                                    .read(workspaceProvider.notifier)
                                    .appearance(
                                      data.requireValue.appearance.copyWith(
                                        mode:
                                            theme.brightness == Brightness.dark
                                            ? 'light'
                                            : 'dark',
                                      ),
                                    )
                              : null,
                          icon: const DeckIcon(Icons.contrast, size: 20),
                        ),
                      ],
                    ),
                  ),
                  if (saveError != null)
                    MaterialBanner(
                      content: Text(saveError),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              ref.read(workspaceProvider.notifier).retrySave(),
                          child: Text(tr(context, 'Réessayer', 'Retry')),
                        ),
                      ],
                    ),
                  Expanded(child: page),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: desktop
          ? null
          : NavigationBar(
              selectedIndex: [0, 1, 2, 3, 5].contains(index)
                  ? [0, 1, 2, 3, 5].indexOf(index)
                  : 0,
              onDestinationSelected: (i) =>
                  context.go(items[[0, 1, 2, 3, 5][i]].$1),
              destinations: [
                for (final i in [0, 1, 2, 3, 5])
                  NavigationDestination(
                    icon: DeckIcon(items[i].$2),
                    label: items[i].$3,
                  ),
              ],
            ),
    );
  }
}

class BuilderEntry extends ConsumerWidget {
  const BuilderEntry({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workspaceProvider);
    if (!state.hasValue) {
      return const FullPage(
        title: 'Atelier',
        fallback: '/templates',
        child: WorkspaceWait(),
      );
    }
    final ws = state.requireValue;
    final p = [
      ...ws.templates,
      ...GameTemplate.builtIn,
    ].where((p) => p.id == id).firstOrNull;
    if (p == null) {
      return const FullPage(
        title: 'Pack introuvable',
        fallback: '/templates',
        child: Text('Ce pack n’est plus installé.'),
      );
    }
    final builtin = GameTemplate.builtIn.any((t) => t.id == id);
    return PackBuilder(
      template: builtin
          ? GameTemplate.fromJson({
              ...p.toJson(),
              'id': 'custom-${DateTime.now().microsecondsSinceEpoch}',
              'name': '${p.name} (copie)',
            })
          : p,
    );
  }
}
