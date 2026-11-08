import 'dart:async';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/metronome_state.dart';
import 'package:amiludo/layers/technical/Feedback/device_feedback.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

const metronomePresets = [60, 90, 120, 160];

class MetronomeTool extends StatefulWidget {
  const MetronomeTool({super.key, this.sound = true, this.haptics = true});
  final bool sound, haptics;

  @override
  State<MetronomeTool> createState() => _MetronomeToolState();
}

class _MetronomeToolState extends State<MetronomeTool> {
  final tool = toolThemeFor('metronome');
  final _clock = Stopwatch();
  Timer? _ticker;
  Duration _due = Duration.zero;
  MetronomeState state = const MetronomeState();
  bool running = false;

  void _beat() {
    DeviceFeedback.tap(sound: widget.sound, haptics: widget.haptics);
  }

  void _start() {
    state = state.restarted();
    _clock
      ..reset()
      ..start();
    _due = state.interval;
    _beat();
    _ticker = Timer.periodic(const Duration(milliseconds: 8), (_) {
      if (!mounted || _clock.elapsed < _due) return;
      _due += state.interval;
      setState(() => state = state.next());
      _beat();
    });
    setState(() => running = true);
  }

  void _stop() {
    _ticker?.cancel();
    _clock.stop();
    setState(() {
      running = false;
      state = state.restarted();
    });
  }

  void _toggle() {
    tool.signal();
    running ? _stop() : _start();
  }

  void _tempo(int bpm) => setState(() => state = state.withBpm(bpm));

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
    final speed = Motion.of(context, Motion.fast);
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
                  for (final bpm in metronomePresets)
                    ChoiceChip(
                      label: Text(l.metronomeBpm(bpm)),
                      selected: state.bpm == bpm,
                      onSelected: (_) => _tempo(bpm),
                    ),
                ],
              ),
              const SizedBox(height: Space.xl),
              Semantics(
                liveRegion: false,
                label: l.metronomeBpm(state.bpm),
                child: ExcludeSemantics(
                  child: Text(
                    '${state.bpm}',
                    style: Numerals.instrument(theme.textTheme.displayLarge),
                  ),
                ),
              ),
              Slider(
                min: MetronomeState.slowest.toDouble(),
                max: MetronomeState.fastest.toDouble(),
                divisions: MetronomeState.fastest - MetronomeState.slowest,
                value: state.bpm.toDouble(),
                label: l.metronomeBpm(state.bpm),
                onChanged: (v) => _tempo(v.round()),
              ),
              const SizedBox(height: Space.lg),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: Space.md,
                children: [
                  for (var i = 0; i < state.beats; i++)
                    AnimatedContainer(
                      duration: speed,
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: running && state.beat == i
                            ? ink
                            : ink.withValues(alpha: i == 0 ? .35 : .16),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Space.xl),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: Space.md,
                runSpacing: Space.md,
                children: [
                  IconButton.outlined(
                    tooltip: l.metronomeBeats(state.beats - 1),
                    onPressed: () =>
                        setState(() => state = state.withBeats(state.beats - 1)),
                    icon: const DeckIcon(Icons.remove),
                  ),
                  FilledButton.icon(
                    onPressed: _toggle,
                    icon: DeckIcon(running ? Icons.pause : Icons.play_arrow),
                    label: Text(running ? l.timerPause : l.timerStart),
                  ),
                  IconButton.outlined(
                    tooltip: l.metronomeBeats(state.beats + 1),
                    onPressed: () =>
                        setState(() => state = state.withBeats(state.beats + 1)),
                    icon: const DeckIcon(Icons.add),
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
