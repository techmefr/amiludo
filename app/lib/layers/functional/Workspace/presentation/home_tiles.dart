import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/tool_catalog.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_tile.dart';
import 'package:amiludo/layers/technical/Theme/deck_icons.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

double tileWidth(BuildContext context) =>
    MediaQuery.sizeOf(context).width < 760 ? 150 : 200;

class HomeWaysToPlay extends StatelessWidget {
  const HomeWaysToPlay({super.key});
  @override
  Widget build(BuildContext context) => ResponsiveGrid(
    minimumWidth: tileWidth(context),
    children: [
      DeckTile(
        icon: Icons.casino_outlined,
        title: context.l10n.workspaceFreeMode,
        onTap: () => context.go('/tools'),
      ),
      DeckTile(
        icon: Icons.dashboard_outlined,
        title: context.l10n.workspaceMyGameCompanions,
        onTap: () => context.go('/templates'),
      ),
      DeckTile(
        icon: Icons.wifi_tethering,
        title: context.l10n.workspaceOpenALobby,
        onTap: () => context.go('/lobby'),
      ),
      DeckTile(
        icon: Icons.login,
        title: context.l10n.workspaceJoinAGame,
        onTap: () => context.go('/join'),
      ),
    ],
  );
}

class HomeFavoriteTools extends StatelessWidget {
  const HomeFavoriteTools({super.key, required this.tools});
  final List<ToolDefinition> tools;
  @override
  Widget build(BuildContext context) => ResponsiveGrid(
    minimumWidth: tileWidth(context),
    children: [
      for (final tool in tools)
        DeckTile(
          icon: toolIcon(tool.id),
          title: tool.title,
          subtitle: tool.subtitle,
          onTap: () => context.push('/tools/${tool.id}'),
        ),
    ],
  );
}
