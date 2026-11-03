import 'dart:async';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Feedback/device_feedback.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: widget.fullscreen ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(context, 'Qui commence ?', 'Who starts?'),
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          tr(
            context,
            'Gardez vos doigts sur l’écran : un contact est choisi après 1,6 seconde. La limite dépend de votre appareil.',
            'Hold your fingers on the area: one is chosen after 1.6 seconds. Contact limit depends on your screen.',
          ),
        ),
        const SizedBox(height: 20),
        if (widget.fullscreen)
          Expanded(
            child: Listener(
              onPointerDown: (e) {
                setState(() {
                  contacts[e.pointer] = e.localPosition;
                  if (contacts.length == 1) {
                    drawn = false;
                    winner = null;
                  }
                });
                schedule();
              },
              onPointerMove: (e) {
                if (contacts.containsKey(e.pointer)) {
                  setState(() => contacts[e.pointer] = e.localPosition);
                }
              },
              onPointerUp: (e) {
                setState(() => contacts.remove(e.pointer));
                if (contacts.isEmpty) {
                  countdown?.cancel();
                } else if (!drawn) {
                  schedule();
                }
              },
              onPointerCancel: (e) {
                setState(() => contacts.remove(e.pointer));
                schedule();
              },
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
                    Center(
                      child: Text(
                        winner != null
                            ? tr(
                                context,
                                'Le contact choisi est illuminé.',
                                'The chosen contact is highlighted.',
                              )
                            : contacts.isEmpty
                            ? tr(
                                context,
                                'POSEZ VOS DOIGTS ICI',
                                'PLACE YOUR FINGERS HERE',
                              )
                            : tr(context, 'On choisit…', 'Choosing…'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    for (final entry in contacts.entries)
                      Positioned(
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
                              ? DeckIcon(
                                  Icons.check,
                                  color: theme.colorScheme.onPrimary,
                                )
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          )
        else
          Listener(
            onPointerDown: (e) {
              setState(() {
                contacts[e.pointer] = e.localPosition;
                if (contacts.length == 1) {
                  drawn = false;
                  winner = null;
                }
              });
              schedule();
            },
            onPointerMove: (e) {
              if (contacts.containsKey(e.pointer)) {
                setState(() => contacts[e.pointer] = e.localPosition);
              }
            },
            onPointerUp: (e) {
              setState(() => contacts.remove(e.pointer));
              if (contacts.isEmpty) {
                countdown?.cancel();
              } else if (!drawn) {
                schedule();
              }
            },
            onPointerCancel: (e) {
              setState(() => contacts.remove(e.pointer));
              schedule();
            },
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
                  Center(
                    child: Text(
                      winner != null
                          ? tr(
                              context,
                              'Le contact choisi est illuminé.',
                              'The chosen contact is highlighted.',
                            )
                          : contacts.isEmpty
                          ? tr(
                              context,
                              'POSEZ VOS DOIGTS ICI',
                              'PLACE YOUR FINGERS HERE',
                            )
                          : tr(context, 'On choisit…', 'Choosing…'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  for (final entry in contacts.entries)
                    Positioned(
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
                            ? DeckIcon(
                                Icons.check,
                                color: theme.colorScheme.onPrimary,
                              )
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
        Text(
          tr(
            context,
            'Ou tirez un prénom, sans multi-touch.',
            'Or pick a name without multi-touch.',
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: widget.names.isEmpty
              ? null
              : () => setState(
                  () => chosen =
                      widget.names[random.integer(0, widget.names.length - 1)],
                ),
          child: Text(tr(context, 'Choisir un joueur', 'Pick a player')),
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
