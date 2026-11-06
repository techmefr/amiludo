import 'dart:async';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/technical/Feedback/device_feedback.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/finger_ring.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

enum FingerMode { first, rank }

class FingerTool extends StatefulWidget {
  const FingerTool({
    super.key,
    required this.names,
    this.haptics = true,
    this.fullscreen = false,
  });
  final bool haptics, fullscreen;
  final List<String> names;
  @override
  State<FingerTool> createState() => _FingerToolState();
}

class _FingerToolState extends State<FingerTool> {
  final contacts = <int, Offset>{};
  final colors = <int, int>{};
  final ranks = <int, int>{};
  final random = RandomTools();
  Timer? countdown;
  FingerMode mode = FingerMode.first;
  int? winner;
  int arrivals = 0;
  String? chosen;
  bool drawn = false;

  void schedule() {
    countdown?.cancel();
    if (contacts.isEmpty || drawn) return;
    countdown = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted || contacts.isEmpty) return;
      setState(() {
        if (mode == FingerMode.first) {
          winner = contacts.keys.elementAt(
            random.integer(0, contacts.length - 1),
          );
        } else {
          for (final (rank, pointer)
              in random.shuffled(contacts.keys).indexed) {
            ranks[pointer] = rank + 1;
          }
        }
        drawn = true;
      });
      DeviceFeedback.selection(haptics: widget.haptics);
    });
  }

  @override
  void dispose() {
    countdown?.cancel();
    super.dispose();
  }

  void reset() {
    drawn = false;
    winner = null;
    ranks.clear();
  }

  void onDown(PointerDownEvent e) {
    setState(() {
      if (contacts.isEmpty) reset();
      contacts[e.pointer] = e.localPosition;
      colors[e.pointer] = arrivals++ % fingerColors.length;
    });
    schedule();
  }

  void onMove(PointerMoveEvent e) {
    if (contacts.containsKey(e.pointer)) {
      setState(() => contacts[e.pointer] = e.localPosition);
    }
  }

  void onUp(PointerEvent e) {
    setState(() => contacts.remove(e.pointer));
    if (contacts.isEmpty) {
      countdown?.cancel();
    } else if (!drawn) {
      schedule();
    }
  }

  void changeMode(FingerMode value) => setState(() {
    countdown?.cancel();
    contacts.clear();
    reset();
    mode = value;
  });

  String hint() => drawn
      ? (mode == FingerMode.first
            ? context.l10n.randomTheChosenContactIsHighlighted
            : context.l10n.randomRankingDone)
      : contacts.isEmpty
      ? context.l10n.randomPlaceYourFingersHere
      : context.l10n.randomChoosing;

  Widget contact(MapEntry<int, Offset> entry) {
    const size = 88.0;
    final color = fingerColors[colors[entry.key] ?? 0];
    final state = mode == FingerMode.first && drawn
        ? (winner == entry.key ? FingerRingState.winner : FingerRingState.dim)
        : FingerRingState.idle;
    return Positioned(
      left: entry.value.dx - size / 2,
      top: entry.value.dy - size / 2,
      child: FingerRing(
        color: color,
        state: state,
        label: ranks[entry.key]?.toString(),
      ),
    );
  }

  Widget area() => Listener(
    onPointerDown: onDown,
    onPointerMove: onMove,
    onPointerUp: onUp,
    onPointerCancel: onUp,
    child: Container(
      height: widget.fullscreen ? double.infinity : 360,
      width: double.infinity,
      decoration: BoxDecoration(
        color: fingerPadColor,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.pill),
        child: Stack(
          children: [
            Center(
              child: Semantics(
                liveRegion: true,
                child: Padding(
                  padding: const EdgeInsets.all(Space.xl),
                  child: Text(
                    hint(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: fingerHintColor),
                  ),
                ),
              ),
            ),
            for (final entry in contacts.entries) contact(entry),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: widget.fullscreen ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<FingerMode>(
          segments: [
            ButtonSegment(
              value: FingerMode.first,
              label: Text(context.l10n.randomModeFirst),
            ),
            ButtonSegment(
              value: FingerMode.rank,
              label: Text(context.l10n.randomModeRank),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (v) => changeMode(v.first),
        ),
        const SizedBox(height: Space.lg),
        if (widget.fullscreen) Expanded(child: area()) else area(),
        const SizedBox(height: Space.xl),
        Text(context.l10n.randomOrPickANameWithout),
        const SizedBox(height: Space.lg),
        FilledButton(
          onPressed: widget.names.isEmpty
              ? null
              : () => setState(
                  () => chosen =
                      widget.names[random.integer(0, widget.names.length - 1)],
                ),
          child: Text(context.l10n.randomPickAPlayer),
        ),
        if (chosen != null)
          Padding(
            padding: const EdgeInsets.only(top: Space.xl),
            child: Semantics(
              liveRegion: true,
              child: Text(chosen!, style: theme.textTheme.headlineMedium),
            ),
          ),
      ],
    );
  }
}
