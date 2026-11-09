import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/chess_clock_state.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

const chessClockPresets = [(1, 0), (3, 2), (5, 3), (10, 0)];

class ChessClockTool extends StatefulWidget {
  const ChessClockTool({super.key});

  @override
  State<ChessClockTool> createState() => _ChessClockToolState();
}

class _ChessClockToolState extends State<ChessClockTool> {
  final tool = toolThemeFor('chess-clock');
  final _clock = Stopwatch();
  Timer? _ticker;
  var _preset = chessClockPresets[1];
  late ChessClockState state = _fresh();
  Duration _last = Duration.zero;

  ChessClockState _fresh() => ChessClockState.start(
    Duration(minutes: _preset.$1),
    Duration(seconds: _preset.$2),
  );

  @override
  void initState() {
    super.initState();
    _clock.start();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final now = _clock.elapsed;
      final delta = now - _last;
      _last = now;
      if (!mounted || !state.running) return;
      final before = state.flagged;
      setState(() => state = state.tick(delta));
      if (before == null && state.flagged != null) tool.signal();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _press(int side) {
    final next = state.press(side);
    if (identical(next, state)) return;
    tool.signal();
    _last = _clock.elapsed;
    setState(() => state = next);
  }

  void _choose((int, int) preset) => setState(() {
    _preset = preset;
    state = _fresh();
  });

  Widget _side(BuildContext context, int side) {
    final l = context.l10n;
    final surface = tool.surface(context, mix: state.active == side ? .3 : .1);
    final ink = tool.ink(surface);
    final flagged = state.flagged == side;
    final time = formatClock(state.remaining[side]);
    return Expanded(
      child: Transform.rotate(
        angle: side == 0 ? pi : 0,
        child: Semantics(
          button: true,
          label: flagged ? '$time, ${l.hourglassDone}' : time,
          child: Material(
            color: flagged ? Theme.of(context).colorScheme.errorContainer : surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.lg),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _press(side),
              child: Center(
                child: ExcludeSemantics(
                  child: Text(
                    time,
                    style: Numerals.instrument(
                      Theme.of(context).textTheme.displayLarge,
                    )?.copyWith(color: flagged ? null : ink),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(Space.lg),
      child: Column(
        children: [
          _side(context, 0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.md),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                for (final preset in chessClockPresets)
                  ChoiceChip(
                    label: Text('${preset.$1} + ${preset.$2}'),
                    selected: _preset == preset,
                    onSelected: (_) => _choose(preset),
                  ),
                IconButton(
                  tooltip: state.paused ? l.timerStart : l.timerPause,
                  onPressed: state.active == null
                      ? null
                      : () => setState(() => state = state.togglePause()),
                  icon: DeckIcon(state.paused ? Icons.play_arrow : Icons.pause),
                ),
                IconButton(
                  tooltip: l.appearanceReset,
                  onPressed: state.pristine
                      ? null
                      : () => setState(() => state = _fresh()),
                  icon: const DeckIcon(Icons.restart_alt),
                ),
              ],
            ),
          ),
          _side(context, 1),
        ],
      ),
    );
  }
}
