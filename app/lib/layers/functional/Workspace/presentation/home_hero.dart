import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Workspace/domain/entities/game_setup_request.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/game_art.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DeckPanel(
      color: theme.colorScheme.surfaceContainerHighest,
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth > 650;
          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!wide) const GameArt(height: 160),
              if (!wide) const SizedBox(height: Space.lg),
              Text(
                context.l10n.workspaceYourFriendsYourTableLet,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: Space.md),
              Text(context.l10n.workspaceScoresChanceAndTimingKeep),
              const SizedBox(height: Space.xl),
              FilledButton.icon(
                onPressed: () => context.push(GameSetupRequest.path),
                icon: const DeckIcon(Icons.add, size: 20),
                label: Text(context.l10n.workspaceNewGame),
              ),
            ],
          );
          return Row(
            children: [
              Expanded(child: text),
              if (wide) const SizedBox(width: 320, child: GameArt(height: 240)),
            ],
          );
        },
      ),
    );
  }
}
