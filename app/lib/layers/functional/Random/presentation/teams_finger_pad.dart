import 'dart:async';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/teams_tool.dart';
import 'package:amiludo/layers/technical/Feedback/device_feedback.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/finger_ring.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class TeamsFingerPad extends StatefulWidget {
  const TeamsFingerPad({
    super.key,
    required this.teamCount,
    this.haptics = true,
  });

  final int teamCount;
  final bool haptics;

  @override
  State<TeamsFingerPad> createState() => _TeamsFingerPadState();
}

class _TeamsFingerPadState extends State<TeamsFingerPad> {
  final random = RandomTools();
  final contacts = <int, Offset>{};
  final assigned = <int, int>{};
  Timer? countdown;

  @override
  void didUpdateWidget(TeamsFingerPad old) {
    super.didUpdateWidget(old);
    if (old.teamCount != widget.teamCount) assigned.clear();
  }

  @override
  void dispose() {
    countdown?.cancel();
    super.dispose();
  }

  void _schedule() {
    countdown?.cancel();
    if (contacts.length < widget.teamCount || assigned.isNotEmpty) return;
    countdown = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted || contacts.length < widget.teamCount) return;
      final teams = random.teams(contacts.keys.toList(), widget.teamCount);
      setState(() {
        for (final (team, pointers) in teams.indexed) {
          for (final pointer in pointers) {
            assigned[pointer] = team;
          }
        }
      });
      DeviceFeedback.selection(haptics: widget.haptics);
    });
  }

  void _down(PointerDownEvent e) {
    setState(() {
      if (contacts.isEmpty) assigned.clear();
      contacts[e.pointer] = e.localPosition;
    });
    _schedule();
  }

  void _move(PointerMoveEvent e) {
    if (contacts.containsKey(e.pointer)) {
      setState(() => contacts[e.pointer] = e.localPosition);
    }
  }

  void _up(PointerEvent e) {
    setState(() => contacts.remove(e.pointer));
    _schedule();
  }

  String _hint() => assigned.isNotEmpty
      ? context.l10n.randomEachFingerShowsItsTeam
      : contacts.length < widget.teamCount
      ? context.l10n.randomEveryonePutAFingerDown(widget.teamCount)
      : context.l10n.randomSplitting;

  Widget _contact(MapEntry<int, Offset> entry) {
    final team = assigned[entry.key];
    return Positioned(
      left: entry.value.dx - 44,
      top: entry.value.dy - 44,
      child: FingerRing(
        color: team == null ? fingerIdleColor : teamColors[team],
        label: team == null ? null : '${team + 1}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: _down,
    onPointerMove: _move,
    onPointerUp: _up,
    onPointerCancel: _up,
    child: Container(
      height: 360,
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
                    _hint(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: fingerHintColor),
                  ),
                ),
              ),
            ),
            for (final entry in contacts.entries) _contact(entry),
          ],
        ),
      ),
    ),
  );
}
