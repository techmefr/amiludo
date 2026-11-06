import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/power.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class PowerView extends StatelessWidget {
  const PowerView({
    super.key,
    required this.state,
    required this.ink,
    required this.onChanged,
  });
  final PowerState state;
  final Color ink;
  final VoidCallback onChanged;

  String statusText(BuildContext context) => switch (state.status) {
    PowerStatus.charging => context.l10n.heroesCharging,
    PowerStatus.ready => context.l10n.heroesReady,
    PowerStatus.used => context.l10n.heroesUsed,
  };

  void apply(void Function() change) {
    change();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ready = state.status == PowerStatus.ready;
    const touch = BoxConstraints(
      minWidth: Targets.minimum,
      minHeight: Targets.minimum,
    );
    return Semantics(
      container: true,
      label:
          '${state.settings.name} ${statusText(context)} '
          '${state.charges}/${state.target}',
      child: Padding(
        padding: const EdgeInsets.only(top: Space.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.settings.name,
                    style: theme.textTheme.titleSmall?.copyWith(color: ink),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.xs),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Radii.sm),
                      child: LinearProgressIndicator(
                        minHeight: Space.sm,
                        value: state.progress,
                        color: ink,
                        backgroundColor: ink.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                  Text(
                    '${statusText(context)}  ${state.charges}/${state.target}',
                    style: theme.textTheme.bodyMedium?.copyWith(color: ink),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: context.l10n.heroesCharge,
              constraints: touch,
              onPressed: state.status == PowerStatus.used
                  ? null
                  : () => apply(state.charge),
              icon: DeckIcon(Icons.bolt, color: ink),
            ),
            FilledButton(
              onPressed: ready ? () => apply(state.use) : null,
              style: FilledButton.styleFrom(
                backgroundColor: ink,
                foregroundColor: theme.colorScheme.surface,
                minimumSize: const Size(Targets.minimum, Targets.minimum),
              ),
              child: Text(context.l10n.heroesUse),
            ),
            IconButton(
              tooltip: context.l10n.heroesRecharge,
              constraints: touch,
              onPressed: () => apply(state.reset),
              icon: DeckIcon(Icons.refresh, color: ink),
            ),
          ],
        ),
      ),
    );
  }
}
