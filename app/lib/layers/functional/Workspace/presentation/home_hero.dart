import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Workspace/domain/entities/game_setup_request.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/demo/demo_player.dart';
import 'package:amiludo/layers/technical/Theme/components/entrance.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({super.key});

  Widget _demo(BuildContext context, bool mockup) {
    final scheme = Theme.of(context).colorScheme;
    return DemoPlayer(
      pauseLabel: context.l10n.demoPause,
      playLabel: context.l10n.demoPlay,
      color: scheme.onPrimary,
      contrast: scheme.primary,
      mockup: mockup,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), scheme = theme.colorScheme;
    final onBrand = scheme.onPrimary;
    final hsl = HSLColor.fromColor(scheme.primary);
    final deep = gradientEnd(
      scheme.primary,
      hsl.withLightness((hsl.lightness * .6).clamp(0.0, 1.0)).toColor(),
      onBrand,
    );
    return Entrance(
      index: 0,
      child: Container(
        padding: const EdgeInsets.all(Space.xl),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radii.pill),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primary, deep],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth > 650;
            final text = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!wide) SizedBox(height: 168, child: _demo(context, false)),
                if (!wide) const SizedBox(height: Space.lg),
                Text(
                  context.l10n.workspaceYourFriendsYourTableLet,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: onBrand,
                  ),
                ),
                const SizedBox(height: Space.md),
                Text(
                  context.l10n.workspaceScoresChanceAndTimingKeep,
                  style: theme.textTheme.bodyLarge?.copyWith(color: onBrand),
                ),
                const SizedBox(height: Space.xl),
                SizedBox(
                  width: wide ? null : double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: onBrand,
                      foregroundColor: scheme.primary,
                    ),
                    onPressed: () => context.push(GameSetupRequest.path),
                    icon: const DeckIcon(Icons.add, size: 20),
                    label: Text(context.l10n.workspaceNewGame),
                  ),
                ),
              ],
            );
            return Row(
              children: [
                Expanded(child: text),
                if (wide)
                  SizedBox(
                    width: 220,
                    height: 280,
                    child: _demo(context, true),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
