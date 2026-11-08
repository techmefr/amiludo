import 'dart:async';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/chess_clock_state.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/turn_timer_state.dart';
import 'package:amiludo/layers/technical/Feedback/device_feedback.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/stopwatch_dial.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

const turnPlayerColors = [
  Color(0xffC2493D),
  Color(0xff3F6FB0),
  Color(0xff2F8F83),
  Color(0xffB38A1D),
  Color(0xff7A3B8F),
  Color(0xffD2603F),
  Color(0xff3F7FA8),
  Color(0xff6F8F2F),
];

const turnTimerSeconds = [15, 30, 60, 90];

class TurnTimerTool extends StatefulWidget {
  const TurnTimerTool({super.key, this.sound = true, this.haptics = true});
  final bool sound, haptics;

  @override
  State<TurnTimerTool> createState() => _TurnTimerToolState();
}

class _TurnTimerToolState extends State<TurnTimerTool> {
  final tool = toolThemeFor('turn-timer');
  final _clock = Stopwatch()..start();
  Timer? _ticker;
  Duration _last = Duration.zero;
  TurnTimerState state = TurnTimerState.of(4, const Duration(seconds: 30));

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final now = _clock.elapsed;
      final delta = now - _last;
      _last = now;
      if (!mounted || !state.running) return;
      final next = state.tick(delta);
      setState(() => state = next);
      if (next.expired) {
        DeviceFeedback.expired(sound: widget.sound, haptics: widget.haptics);
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _pass() {
    tool.signal();
    _last = _clock.elapsed;
    setState(() => state = state.pass());
  }

  void _setup({int? players, int? seconds}) => setState(
    () => state = TurnTimerState.of(
      players ?? state.players,
      Duration(seconds: seconds ?? state.perTurn.inSeconds),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final accent = ToolTheme(
      accent: turnPlayerColors[state.current % turnPlayerColors.length],
    );
    final surface = accent.surface(context, mix: .22);
    final ink = accent.ink(surface);
    final time = formatClock(state.remaining);
    final name = l.turnTimerPlayer(state.current + 1);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Space.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: [
                  for (var n = 2; n <= 8; n++)
                    ChoiceChip(
                      label: Text('$n'),
                      selected: state.players == n,
                      onSelected: (_) => _setup(players: n),
                    ),
                ],
              ),
              const SizedBox(height: Space.sm),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: [
                  for (final s in turnTimerSeconds)
                    ChoiceChip(
                      label: Text(l.hourglassSeconds(s)),
                      selected: state.perTurn.inSeconds == s,
                      onSelected: (_) => _setup(seconds: s),
                    ),
                ],
              ),
              const SizedBox(height: Space.xl),
              Material(
                color: surface,
                shape: const CircleBorder(),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CustomPaint(
                    painter: StopwatchDial(
                      progress: state.fraction,
                      track: ink.withValues(alpha: .18),
                      sweep: state.expired ? theme.colorScheme.error : ink,
                      marks: ink.withValues(alpha: .45),
                    ),
                    child: Semantics(
                      liveRegion: true,
                      label: '$name, $time',
                      child: ExcludeSemantics(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: ink,
                              ),
                            ),
                            Text(
                              time,
                              style: Numerals.instrument(
                                theme.textTheme.displayMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Space.lg),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: Space.md,
                runSpacing: Space.md,
                children: [
                  FilledButton.icon(
                    onPressed: _pass,
                    icon: const DeckIcon(Icons.skip_next),
                    label: Text(l.turnTimerNext),
                  ),
                  OutlinedButton.icon(
                    onPressed: state.turns == 0 && !state.running
                        ? null
                        : () => setState(() => state = state.toggled()),
                    icon: DeckIcon(
                      state.running ? Icons.pause : Icons.play_arrow,
                    ),
                    label: Text(state.running ? l.timerPause : l.timerStart),
                  ),
                  IconButton(
                    tooltip: l.appearanceReset,
                    onPressed: state.pristine
                        ? null
                        : () => setState(() => state = state.reset()),
                    icon: const DeckIcon(Icons.restart_alt),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
