import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Workspace/presentation/cubit/workspace_cubit.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/cubit/workspace_state.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/workspace_gate.dart';
import 'package:amiludo/layers/technical/About/app_info.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.path, required this.child});
  final String path;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceCubit>(),
        state = workspace.state,
        theme = Theme.of(context);
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
    final page = WorkspaceGate(
      child: SingleChildScrollView(
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
            child: child,
          ),
        ),
      ),
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
                    Row(
                      children: [
                        Image.asset(
                          'assets/brand/amiludo-mark.png',
                          width: 36,
                          height: 36,
                          excludeFromSemantics: true,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'amiLudo',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.brightness == Brightness.dark
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toutes vos parties',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontFamily: 'LilGrotesk',
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
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
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
                        'amiLudo · Alpha\nSans compte. Sans publicité.',
                        'amiLudo · Alpha\nNo account. No ads.',
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
                          Image.asset(
                            'assets/brand/amiludo-mark.png',
                            width: 32,
                            height: 32,
                            semanticLabel: 'amiLudo',
                          ),
                        if (!desktop) const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'amiLudo · ${items[index < 0 ? 0 : index].$3}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium,
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
                          onPressed: state.status == WorkspaceStatus.ready
                              ? () => workspace.changeAppearance(
                                  state.workspace.appearance.copyWith(
                                    mode: theme.brightness == Brightness.dark
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
                  if (state.saveFailed)
                    MaterialBanner(
                      content: Text(
                        tr(
                          context,
                          'Enregistrement impossible. Exportez vos données avant de fermer.',
                          'Saving failed. Export your data before closing.',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: workspace.retrySave,
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
