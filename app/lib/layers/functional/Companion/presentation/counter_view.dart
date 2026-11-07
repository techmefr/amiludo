import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/counter.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/functional/Companion/presentation/counter_numeral.dart';
import 'package:amiludo/layers/technical/Theme/components/stone_slab.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const _maxSymbols = 12;

class CounterView extends StatefulWidget {
  const CounterView({super.key, required this.state, this.onChanged});
  final CounterState state;
  final VoidCallback? onChanged;

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  CounterState get counter => widget.state;

  void apply(VoidCallback change) {
    setState(change);
    widget.onChanged?.call();
  }

  bool get symbolic {
    final high = counter.settings.maximum;
    return high != null && high <= _maxSymbols;
  }

  @override
  Widget build(BuildContext context) {
    final settings = counter.settings;
    final background = Color(settings.color);
    const ink = StonePalette.cream;
    final high = settings.maximum;
    final danger = high != null && high > 10 && counter.value <= 5;
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      label: '${settings.name} ${numberText(counter.value)}',
      child: StoneSlab(
        accent: background,
        halo: danger ? StonePalette.ember : null,
        child: IconTheme(
          data: IconThemeData(color: ink),
          child: Padding(
            padding: const EdgeInsets.all(Space.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (settings.name.isNotEmpty)
                  Text(
                    settings.name,
                    style: theme.textTheme.titleMedium?.copyWith(color: ink),
                  ),
                Row(
                  children: [
                    _Step(
                      icon: Icons.remove,
                      tooltip: context.l10n.counterDecrease,
                      onTap: () => apply(counter.decrease),
                    ),
                    Expanded(
                      child: _Reading(counter: counter, ink: ink),
                    ),
                    _Step(
                      icon: Icons.add,
                      tooltip: context.l10n.counterIncrease,
                      onTap: () => apply(counter.increase),
                    ),
                  ],
                ),
                if (counter.triggersOutcome)
                  Padding(
                    padding: const EdgeInsets.only(top: Space.sm),
                    child: Text(
                      settings.outcome == CounterOutcome.eliminated
                          ? context.l10n.counterEliminated
                          : context.l10n.counterSkipsTurn,
                      style: theme.textTheme.labelLarge?.copyWith(color: ink),
                    ),
                  ),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    TextButton(
                      onPressed: counter.canUndo
                          ? () => apply(counter.undo)
                          : null,
                      style: TextButton.styleFrom(foregroundColor: ink),
                      child: Text(context.l10n.gameUndo),
                    ),
                    TextButton(
                      onPressed: () => apply(counter.reset),
                      style: TextButton.styleFrom(foregroundColor: ink),
                      child: Text(context.l10n.appearanceReset),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => IconButton.filled(
    tooltip: tooltip,
    style: IconButton.styleFrom(
      backgroundColor: StonePalette.edge,
      foregroundColor: StonePalette.cream,
      side: const BorderSide(color: StonePalette.gold, width: 1.5),
    ),
    constraints: const BoxConstraints(
      minWidth: Targets.minimum + Space.sm,
      minHeight: Targets.minimum + Space.sm,
    ),
    onPressed: onTap,
    icon: DeckIcon(icon, size: 28),
  );
}

class _Reading extends StatelessWidget {
  const _Reading({required this.counter, required this.ink});
  final CounterState counter;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final settings = counter.settings;
    final number = CounterNumeral(
      text: numberText(counter.value),
      value: counter.value.toDouble(),
    );
    final high = settings.maximum;
    final low = settings.minimum ?? 0;
    switch (settings.display) {
      case CounterDisplay.bar when high != null && high > low:
        return Column(
          children: [
            number,
            Padding(
              padding: const EdgeInsets.only(top: Space.sm),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Radii.sm),
                child: LinearProgressIndicator(
                  minHeight: Space.md,
                  value: ((counter.value - low) / (high - low)).clamp(0, 1),
                  color: ink,
                  backgroundColor: ink.withValues(alpha: 0.25),
                ),
              ),
            ),
          ],
        );
      case CounterDisplay.hearts || CounterDisplay.pips
          when high != null && high <= _maxSymbols:
        return Column(
          children: [
            number,
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < high.round(); i++)
                  Icon(
                    settings.display == CounterDisplay.hearts
                        ? (i < counter.value
                              ? Icons.favorite
                              : Icons.favorite_border)
                        : (i < counter.value
                              ? Icons.circle
                              : Icons.circle_outlined),
                    size: 20,
                    color: ink,
                  ),
              ],
            ),
          ],
        );
      default:
        return number;
    }
  }
}
