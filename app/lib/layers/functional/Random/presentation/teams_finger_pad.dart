import 'dart:async';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/teams_tool.dart';
import 'package:amiludo/layers/technical/Feedback/device_feedback.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

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
      ? tr(
          context,
          'Chaque doigt a sa couleur et son numéro d’équipe.',
          'Each finger shows its team colour and number.',
        )
      : contacts.length < widget.teamCount
      ? tr(
          context,
          'POSEZ CHACUN UN DOIGT (au moins ${widget.teamCount})',
          'EVERYONE PUT A FINGER DOWN (at least ${widget.teamCount})',
        )
      : tr(context, 'On répartit…', 'Splitting…');

  Widget _contact(MapEntry<int, Offset> entry) {
    final team = assigned[entry.key];
    final theme = Theme.of(context);
    return Positioned(
      left: entry.value.dx - 36,
      top: entry.value.dy - 36,
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: team == null ? theme.colorScheme.surface : teamColors[team],
          border: Border.all(color: theme.colorScheme.primary, width: 3),
        ),
        child: team == null
            ? null
            : Text(
                '${team + 1}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Center(
            child: Semantics(
              liveRegion: true,
              child: Text(_hint(), textAlign: TextAlign.center),
            ),
          ),
          for (final entry in contacts.entries) _contact(entry),
        ],
      ),
    ),
  );
}
