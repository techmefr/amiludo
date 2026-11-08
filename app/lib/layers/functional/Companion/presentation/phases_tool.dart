import 'dart:async';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/chess_clock_state.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/phase_sequence_state.dart';
import 'package:amiludo/layers/technical/Feedback/device_feedback.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/stopwatch_dial.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class PhasesTool extends StatefulWidget {
  const PhasesTool({super.key, this.sound = true, this.haptics = true});
  final bool sound, haptics;

  @override
  State<PhasesTool> createState() => _PhasesToolState();
}

class _PhasesToolState extends State<PhasesTool> {
  final tool = toolThemeFor('phases');
  final _clock = Stopwatch()..start();
  Timer? _ticker;
  Duration _last = Duration.zero;
  PhaseSequenceState state = PhaseSequenceState.of(const [
    Duration(seconds: 60),
    Duration(seconds: 180),
    Duration(seconds: 30),
  ]);

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final now = _clock.elapsed;
      final delta = now - _last;
      _last = now;
      if (!mounted || !state.running) return;
      final next = state.tick(delta);
      final moved = next.index != state.index || next.round != state.round;
      setState(() => state = next);
      if (moved) {
        DeviceFeedback.expired(sound: widget.sound, haptics: widget.haptics);
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _set(PhaseSequenceState next) => setState(() => state = next);

  void _toggle() {
    tool.signal();
    _last = _clock.elapsed;
    _set(state.toggled());
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final surface = tool.surface(context);
    final ink = tool.ink(surface);
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
                  for (var i = 0; i < state.durations.length; i++)
                    ChoiceChip(
                      label: Text(
                        '${i + 1} · ${formatClock(state.durations[i])}',
                      ),
                      selected: state.index == i,
                      onSelected: state.running ? null : (_) => _set(state.select(i)),
                    ),
                ],
              ),
              const SizedBox(height: Space.xl),
              AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: StopwatchDial(
                    progress: state.fraction,
                    track: ink.withValues(alpha: .16),
                    sweep: ink,
                    marks: ink.withValues(alpha: .45),
                  ),
                  child: Semantics(
                    liveRegion: true,
                    label:
                        '${l.phasesPhase(state.index + 1)}, ${formatClock(state.remaining)}',
                    child: ExcludeSemantics(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l.phasesPhase(state.index + 1),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: ink,
                            ),
                          ),
                          Text(
                            formatClock(state.remaining),
                            style: Numerals.instrument(
                              theme.textTheme.displayMedium,
                            ),
                          ),
                          Text(
                            l.phasesRound(state.round),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Space.lg),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: Space.md,
                runSpacing: Space.md,
                children: [
                  IconButton.outlined(
                    tooltip: '- ${l.hourglassSeconds(30)}',
                    onPressed: state.running
                        ? null
                        : () => _set(state.adjusted(-PhaseSequenceState.step)),
                    icon: const DeckIcon(Icons.remove),
                  ),
                  FilledButton.icon(
                    onPressed: _toggle,
                    icon: DeckIcon(
                      state.running ? Icons.pause : Icons.play_arrow,
                    ),
                    label: Text(state.running ? l.timerPause : l.timerStart),
                  ),
                  IconButton.outlined(
                    tooltip: '+ ${l.hourglassSeconds(30)}',
                    onPressed: state.running
                        ? null
                        : () => _set(state.adjusted(PhaseSequenceState.step)),
                    icon: const DeckIcon(Icons.add),
                  ),
                  IconButton(
                    tooltip: l.appearanceReset,
                    onPressed: state.pristine ? null : () => _set(state.reset()),
                    icon: const DeckIcon(Icons.restart_alt),
                  ),
                ],
              ),
              const SizedBox(height: Space.md),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: Space.md,
                children: [
                  TextButton.icon(
                    onPressed: state.running ? null : () => _set(state.added()),
                    icon: const DeckIcon(Icons.add),
                    label: Text(l.phasesAdd),
                  ),
                  TextButton.icon(
                    onPressed: state.running
                        ? null
                        : () => _set(state.removed()),
                    icon: const DeckIcon(Icons.remove),
                    label: Text(l.phasesRemove),
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
