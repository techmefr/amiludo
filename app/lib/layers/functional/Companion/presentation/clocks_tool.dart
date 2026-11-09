import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/progress_clock.dart';
import 'package:amiludo/layers/functional/Companion/presentation/clock_disk.dart';
import 'package:amiludo/layers/functional/Companion/presentation/name_dialog.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class ClocksTool extends StatefulWidget {
  const ClocksTool({super.key});

  @override
  State<ClocksTool> createState() => _ClocksToolState();
}

class _ClocksToolState extends State<ClocksTool> {
  List<ProgressClock> clocks = const [];
  int segments = 6;
  final tool = toolThemeFor('clocks');

  Future<void> _add() async {
    final l = context.l10n;
    final name = await showNameDialog(
      context,
      title: l.clocksAdd,
      label: l.clocksName,
    );
    if (name != null) setState(() => clocks = addClock(clocks, name, segments));
  }

  void _step(int index, int delta) {
    tool.signal();
    setState(() => clocks = stepClock(clocks, index, delta));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final ink = tool.ink(tool.surface(context));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final size in clockSizes)
              ChoiceChip(
                label: Text(l.clocksSegments(size)),
                selected: size == segments,
                onSelected: (_) => setState(() => segments = size),
              ),
            FilledButton.icon(
              onPressed: _add,
              icon: const DeckIcon(Icons.add),
              label: Text(l.clocksAdd),
            ),
          ],
        ),
        const SizedBox(height: Space.lg),
        if (clocks.isEmpty) Text(l.clocksEmpty),
        Wrap(
          spacing: Space.lg,
          runSpacing: Space.lg,
          children: [
            for (final (i, clock) in clocks.indexed)
              SizedBox(
                width: 200,
                child: Semantics(
                  container: true,
                  label: '${clock.name} ${clock.filled} / ${clock.segments}',
                  child: Column(
                    children: [
                      ExcludeSemantics(
                        child: Text(
                          clock.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      SizedBox(
                        height: 160,
                        child: CustomPaint(
                          size: const Size.square(160),
                          painter: ClockDisk(
                            segments: clock.segments,
                            filled: clock.filled,
                            fill: clock.full ? scheme.error : ink,
                            line: scheme.outline,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            tooltip: '${l.counterDecrease} ${clock.name}',
                            onPressed: () => _step(i, -1),
                            icon: const DeckIcon(Icons.remove),
                          ),
                          IconButton(
                            tooltip: '${l.counterIncrease} ${clock.name}',
                            onPressed: () => _step(i, 1),
                            icon: const DeckIcon(Icons.add),
                          ),
                          IconButton(
                            tooltip: l.clocksRemove(clock.name),
                            onPressed: () =>
                                setState(() => clocks = removeClock(clocks, i)),
                            icon: const DeckIcon(Icons.close),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
