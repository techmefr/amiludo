import 'dart:async';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_mode_selector.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_name_picker.dart';
import 'package:amiludo/layers/technical/Feedback/device_feedback.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/finger_ring.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class FingerTool extends StatefulWidget {
  const FingerTool({
    super.key,
    required this.names,
    this.haptics = true,
    this.fullscreen = false,
    this.onTint,
  });
  final bool haptics, fullscreen;
  final List<String> names;
  final ValueChanged<Color?>? onTint;
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
      widget.onTint?.call(winnerColor());
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
    widget.onTint?.call(null);
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
    const size = fingerRingSize;
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

  Color? winnerColor() => mode == FingerMode.first && drawn && winner != null
      ? fingerColors[colors[winner] ?? 0]
      : null;

  Widget area() => Listener(
    onPointerDown: onDown,
    onPointerMove: onMove,
    onPointerUp: onUp,
    onPointerCancel: onUp,
    child: AnimatedContainer(
      duration: Motion.of(context, Motion.slow),
      curve: Motion.curve,
      height: widget.fullscreen ? double.infinity : 360,
      width: double.infinity,
      decoration: BoxDecoration(
        color: winnerColor() ?? fingerPadColor,
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: winnerColor() == null
                          ? fingerHintColor
                          : fingerWinnerDiscColor,
                    ),
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
    return Column(
      mainAxisSize: widget.fullscreen ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FingerModeSelector(mode: mode, onChanged: changeMode),
        const SizedBox(height: Space.lg),
        if (widget.fullscreen) Expanded(child: area()) else area(),
        FingerNamePicker(
          names: widget.names,
          chosen: chosen,
          onPick: () => setState(
            () => chosen =
                widget.names[random.integer(0, widget.names.length - 1)],
          ),
        ),
      ],
    );
  }
}
