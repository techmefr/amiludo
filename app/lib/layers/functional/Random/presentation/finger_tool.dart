import 'dart:async';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Feedback/device_feedback.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
  final random = RandomTools();
  Timer? countdown;
  int? winner;
  String? chosen;
  bool drawn = false;
  void schedule() {
    countdown?.cancel();
    if (contacts.isNotEmpty && !drawn) {
      countdown = Timer(const Duration(milliseconds: 1600), () {
        if (!mounted || contacts.isEmpty) return;
        setState(() {
          winner = contacts.keys.elementAt(
            random.integer(0, contacts.length - 1),
          );
          drawn = true;
        });
        DeviceFeedback.selection(haptics: widget.haptics);
      });
    }
  }

  @override
  void dispose() {
    countdown?.cancel();
    super.dispose();
  }

  void onDown(PointerDownEvent e) {
    setState(() {
      contacts[e.pointer] = e.localPosition;
      if (contacts.length == 1) {
        drawn = false;
        winner = null;
      }
    });
    schedule();
  }

  void onMove(PointerMoveEvent e) {
    if (contacts.containsKey(e.pointer)) {
      setState(() => contacts[e.pointer] = e.localPosition);
    }
  }

  void onUp(PointerUpEvent e) {
    setState(() => contacts.remove(e.pointer));
    if (contacts.isEmpty) {
      countdown?.cancel();
    } else if (!drawn) {
      schedule();
    }
  }

  void onCancel(PointerCancelEvent e) {
    setState(() => contacts.remove(e.pointer));
    schedule();
  }

  String hint() => winner != null
      ? context.l10n.randomTheChosenContactIsHighlighted
      : contacts.isEmpty
      ? context.l10n.randomPlaceYourFingersHere
      : context.l10n.randomChoosing;

  Widget contact(ThemeData theme, MapEntry<int, Offset> entry) => Positioned(
    left: entry.value.dx - 32,
    top: entry.value.dy - 32,
    child: Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: winner == entry.key
            ? theme.colorScheme.primary
            : theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.primary,
          width: winner == entry.key ? 8 : 3,
        ),
      ),
      child: winner == entry.key
          ? DeckIcon(Icons.check, color: theme.colorScheme.onPrimary)
          : null,
    ),
  );

  Widget area(ThemeData theme) => Listener(
    onPointerDown: onDown,
    onPointerMove: onMove,
    onPointerUp: onUp,
    onPointerCancel: onCancel,
    child: Container(
      height: widget.fullscreen ? double.infinity : 280,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Center(child: Text(hint(), textAlign: TextAlign.center)),
          for (final entry in contacts.entries) contact(theme, entry),
        ],
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
        Text(context.l10n.randomHoldYourFingersOnThe),
        const SizedBox(height: 20),
        if (widget.fullscreen) Expanded(child: area(theme)) else area(theme),
        const SizedBox(height: 24),
        Text(context.l10n.randomOrPickANameWithout),
        const SizedBox(height: 16),
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
            padding: const EdgeInsets.only(top: 20),
            child: Semantics(
              liveRegion: true,
              child: Text(chosen!, style: theme.textTheme.headlineMedium),
            ),
          ),
      ],
    );
  }
}
