import 'dart:async';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/stopwatch_state.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/stopwatch_dial.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class StopwatchTool extends StatefulWidget {
  const StopwatchTool({super.key});

  @override
  State<StopwatchTool> createState() => _StopwatchToolState();
}

class _StopwatchToolState extends State<StopwatchTool> {
  final _clock = Stopwatch();
  Timer? _ticker;
  Duration _base = Duration.zero;
  StopwatchState state = const StopwatchState();
  final tool = toolThemeFor('stopwatch');

  void _tick() {
    if (mounted) setState(() => state = state.withElapsed(_base + _clock.elapsed));
  }

  void _toggle() {
    tool.signal();
    if (state.running) {
      _ticker?.cancel();
      _base += _clock.elapsed;
      _clock
        ..stop()
        ..reset();
      setState(() => state = state.withElapsed(_base).toggled());
      return;
    }
    _clock.start();
    _ticker = Timer.periodic(const Duration(milliseconds: 33), (_) => _tick());
    setState(() => state = state.toggled());
  }

  void _lap() {
    tool.signal();
    setState(() => state = state.lapped());
  }

  void _reset() {
    _ticker?.cancel();
    _clock
      ..stop()
      ..reset();
    _base = Duration.zero;
    setState(() => state = state.reset());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final surface = tool.surface(context);
    final ink = tool.ink(surface);
    final time = formatStopwatch(state.elapsed);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Space.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: StopwatchDial(
                    progress: (state.elapsed.inMilliseconds % 60000) / 60000,
                    track: ink.withValues(alpha: .16),
                    sweep: ink,
                    marks: ink.withValues(alpha: .45),
                  ),
                  child: Center(
                    child: Semantics(
                      label: time,
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
              const SizedBox(height: Space.xl),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: Space.md,
                runSpacing: Space.md,
                children: [
                  FilledButton.icon(
                    onPressed: _toggle,
                    icon: DeckIcon(state.running ? Icons.pause : Icons.play_arrow),
                    label: Text(state.running ? l.timerPause : l.timerStart),
                  ),
                  OutlinedButton.icon(
                    onPressed: state.running ? _lap : null,
                    icon: const DeckIcon(Icons.flag_outlined),
                    label: Text(l.stopwatchLap),
                  ),
                  TextButton.icon(
                    onPressed: state.pristine ? null : _reset,
                    icon: const DeckIcon(Icons.restart_alt),
                    label: Text(l.appearanceReset),
                  ),
                ],
              ),
              const SizedBox(height: Space.lg),
              for (var i = state.laps.length - 1; i >= 0; i--)
                ListTile(
                  dense: true,
                  title: Text(l.stopwatchLapNumber(i + 1)),
                  trailing: Text(
                    formatStopwatch(state.lapLength(i)),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFeatures: Numerals.tabular,
                      color: state.lapLength(i) == state.fastest ? ink : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
