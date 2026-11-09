import 'dart:async';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/chess_clock_state.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/countdown_state.dart';
import 'package:amiludo/layers/technical/Feedback/device_feedback.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/stopwatch_dial.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

const countdownPresets = [1, 3, 5, 10, 15];

class CountdownTool extends StatefulWidget {
  const CountdownTool({super.key, this.sound = true, this.haptics = true});
  final bool sound, haptics;

  @override
  State<CountdownTool> createState() => _CountdownToolState();
}

class _CountdownToolState extends State<CountdownTool> {
  final tool = toolThemeFor('countdown');
  final _clock = Stopwatch()..start();
  Timer? _ticker;
  Duration _last = Duration.zero;
  CountdownState state = CountdownState.of(const Duration(minutes: 5));

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
      if (next.finished) {
        DeviceFeedback.expired(sound: widget.sound, haptics: widget.haptics);
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _toggle() {
    tool.signal();
    _last = _clock.elapsed;
    setState(() => state = state.toggled());
  }

  void _set(CountdownState next) => setState(() => state = next);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final surface = tool.surface(context);
    final ink = tool.ink(surface);
    final time = formatClock(state.remaining);
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
                  for (final minutes in countdownPresets)
                    ChoiceChip(
                      label: Text('$minutes min'),
                      selected: state.total == Duration(minutes: minutes),
                      onSelected: state.running
                          ? null
                          : (_) => _set(
                              CountdownState.of(Duration(minutes: minutes)),
                            ),
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
                    sweep: state.finished ? theme.colorScheme.error : ink,
                    marks: ink.withValues(alpha: .45),
                  ),
                  child: Center(
                    child: Semantics(
                      liveRegion: state.finished,
                      label: state.finished ? l.hourglassDone : time,
                      child: ExcludeSemantics(
                        child: Text(
                          time,
                          style: Numerals.instrument(
                            theme.textTheme.displayMedium,
                          ),
                        ),
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
                        : () => _set(state.adjusted(-CountdownState.step)),
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
                        : () => _set(state.adjusted(CountdownState.step)),
                    icon: const DeckIcon(Icons.add),
                  ),
                  IconButton(
                    tooltip: l.appearanceReset,
                    onPressed: state.pristine ? null : () => _set(state.reset()),
                    icon: const DeckIcon(Icons.restart_alt),
                  ),
                ],
              ),
              if (state.finished) ...[
                const SizedBox(height: Space.lg),
                Text(l.hourglassDone, style: theme.textTheme.titleLarge),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
