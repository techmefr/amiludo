import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Workspace/presentation/cubit/workspace_cubit.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/cubit/workspace_state.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/workspace_gate.dart';
import 'package:amiludo/layers/technical/About/app_info.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

typedef NavItem = (String route, IconData icon, String label);

const _barRoutes = [0, 1, 2, 3, 4];

List<NavItem> navItems(BuildContext context) => [
  ('/', Icons.home_outlined, context.l10n.workspaceHome),
  ('/game', Icons.dashboard_outlined, context.l10n.workspaceMyGame),
  ('/tools', Icons.casino_outlined, context.l10n.workspaceTools),
  ('/library', Icons.shelves, context.l10n.workspaceShelf),
  ('/friends', Icons.people_outline, context.l10n.workspaceFriends),
  ('/evenings', Icons.event_outlined, context.l10n.workspaceNights),
  ('/history', Icons.history, context.l10n.workspaceHistory),
  ('/appearance', Icons.tune, context.l10n.workspaceStyle),
];

int navIndex(List<NavItem> items, String path) => switch (path) {
  '/timer' => 2,
  '/templates' => 3,
  _ => items.indexWhere((i) => i.$1 == path),
};

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.path, required this.child});
  final String path;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final items = navItems(context);
    final index = navIndex(items, path);
    final size = MediaQuery.sizeOf(context);
    final largeText = MediaQuery.textScalerOf(context).scale(16) > 20;
    final desktop = size.width >= 1000 && !largeText;
    final rail = !desktop && size.width > size.height;
    final compact = size.height < 500;
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (desktop) _Sidebar(items: items, path: path),
            if (rail) _Rail(items: items, index: index),
            Expanded(
              child: Column(
                children: [
                  _Header(
                    label: items[index < 0 ? 0 : index].$3,
                    desktop: desktop,
                    compact: compact,
                  ),
                  const _SaveFailedBanner(),
                  Expanded(
                    child: _Page(
                      path: path,
                      desktop: desktop,
                      compact: compact,
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: desktop || rail
          ? null
          : _BottomBar(items: items, index: index),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    required this.path,
    required this.desktop,
    required this.compact,
    required this.child,
  });
  final String path;
  final bool desktop, compact;
  final Widget child;
  @override
  Widget build(BuildContext context) => WorkspaceGate(
    child: SingleChildScrollView(
      key: PageStorageKey(path),
      padding: EdgeInsets.fromLTRB(
        desktop ? 48 : 20,
        desktop ? 40 : (compact ? 16 : 28),
        desktop ? 48 : 20,
        48,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    ),
  );
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
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
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.items, required this.path});
  final List<NavItem> items;
  final String path;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 240,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: theme.colorScheme.outline)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
      child: LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Brand(),
                  const SizedBox(height: 8),
                  Text(
                    'Toutes vos parties',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontFamily: 'LilGrotesk',
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 48),
                  for (final item in items)
                    _SidebarTile(
                      item: item,
                      selected: navIndex(items, path) == items.indexOf(item),
                    ),
                  const Spacer(),
                  Text(
                    context.l10n.workspaceDataOnThisDevice,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.workspaceAmiludoAlphaNoAccountNo,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({required this.item, required this.selected});
  final NavItem item;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (route, icon, label) = item;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        selected: selected,
        selectedColor: theme.colorScheme.primary,
        selectedTileColor: theme.colorScheme.surfaceContainerHighest,
        leading: DeckIcon(icon, size: 20),
        title: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: () => context.go(route),
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.items, required this.index});
  final List<NavItem> items;
  final int index;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border(
        right: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
    ),
    child: NavigationRail(
      selectedIndex: index < 0 ? null : index,
      labelType: NavigationRailLabelType.none,
      groupAlignment: 0,
      onDestinationSelected: (i) => context.go(items[i].$1),
      destinations: [
        for (final (_, icon, label) in items)
          NavigationRailDestination(
            icon: Tooltip(message: label, child: DeckIcon(icon)),
            label: Text(label),
          ),
      ],
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.label,
    required this.desktop,
    required this.compact,
  });
  final String label;
  final bool desktop, compact;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: desktop ? 80 : (compact ? 52 : 64),
      padding: EdgeInsets.symmetric(horizontal: desktop ? 48 : 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: Row(
        children: [
          if (!desktop) ...[
            Image.asset(
              'assets/brand/amiludo-mark.png',
              width: 32,
              height: 32,
              semanticLabel: 'amiLudo',
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(
              'amiLudo · $label',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium,
            ),
          ),
          if (desktop)
            Text('Alpha $appVersion', style: theme.textTheme.labelSmall),
          _HeaderActions(desktop: desktop),
        ],
      ),
    );
  }
}

class _HeaderActions extends StatelessWidget {
  const _HeaderActions({required this.desktop});
  final bool desktop;
  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceCubit>(), state = workspace.state;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (desktop)
          IconButton(
            tooltip: context.l10n.workspaceAboutAndFeedback,
            onPressed: () => showProjectInfo(context),
            icon: const DeckIcon(Icons.info_outline, size: 20),
          ),
        IconButton(
          tooltip: context.l10n.workspaceMyProfile,
          onPressed: () => context.go('/account'),
          icon: const DeckIcon(Icons.account_circle_outlined, size: 20),
        ),
        if (desktop)
          IconButton(
            tooltip: context.l10n.workspaceHistory,
            onPressed: () => context.go('/history'),
            icon: const DeckIcon(Icons.history, size: 20),
          ),
        if (!desktop)
          IconButton(
            tooltip: context.l10n.workspaceStyle,
            onPressed: () => context.go('/appearance'),
            icon: const DeckIcon(Icons.tune, size: 20),
          ),
        IconButton(
          tooltip: context.l10n.workspaceToggleLight,
          onPressed: state.status == WorkspaceStatus.ready
              ? () => workspace.changeAppearance(
                  state.workspace.appearance.copyWith(
                    mode: dark ? 'light' : 'dark',
                  ),
                )
              : null,
          icon: const DeckIcon(Icons.contrast, size: 20),
        ),
      ],
    );
  }
}

class _SaveFailedBanner extends StatelessWidget {
  const _SaveFailedBanner();
  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceCubit>();
    if (!workspace.state.saveFailed) return const SizedBox.shrink();
    return MaterialBanner(
      content: Text(context.l10n.workspaceSavingFailedExportYourData),
      actions: [
        TextButton(
          onPressed: workspace.retrySave,
          child: Text(context.l10n.workspaceRetry),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.items, required this.index});
  final List<NavItem> items;
  final int index;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = _barRoutes.contains(index);
    return NavigationBarTheme(
      data: active
          ? NavigationBarTheme.of(context)
          : NavigationBarTheme.of(context).copyWith(
              indicatorColor: Colors.transparent,
              iconTheme: WidgetStatePropertyAll(
                IconThemeData(color: theme.colorScheme.onSurfaceVariant),
              ),
              labelTextStyle: WidgetStatePropertyAll(
                theme.textTheme.labelMedium,
              ),
            ),
      child: NavigationBar(
        selectedIndex: active ? _barRoutes.indexOf(index) : 0,
        onDestinationSelected: (i) => context.go(items[_barRoutes[i]].$1),
        destinations: [
          for (final i in _barRoutes)
            NavigationDestination(
              icon: DeckIcon(items[i].$2),
              label: items[i].$3,
            ),
        ],
      ),
    );
  }
}
