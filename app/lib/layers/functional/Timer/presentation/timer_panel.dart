import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../technical/Theme/deck_widgets.dart';
import '../../../technical/Theme/deck_theme.dart';
import '../../Workspace/workspace_controller.dart';
import '../domain/game_clock.dart';

class TimerPanel extends ConsumerStatefulWidget {
  const TimerPanel({super.key});
  @override
  ConsumerState<TimerPanel> createState() => _TimerPanelState();
}

class _TimerPanelState extends ConsumerState<TimerPanel> {
  Timer? ticker;
  bool alerted = false;
  @override
  void initState() {
    super.initState();
    ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) return;
      final ws = ref.read(workspaceProvider).value;
      if (ws == null) return;
      final controller = ref.read(workspaceProvider.notifier);
      if (ws.clock.isRunning &&
          ws.clock.remainingAt(controller.time.now) == 0 &&
          !alerted) {
        alerted = true;
        controller.clock(ws.clock.pause(controller.time.now));
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.alert);
        notify(
          context,
          tr(
            context,
            'Temps écoulé. À vous de passer la main.',
            'Time is up. Pass the turn.',
          ),
        );
      }
      if (ws.clock.remainingAt(controller.time.now) > 0) alerted = false;
      setState(() {});
    });
  }

  @override
  void dispose() {
    ticker?.cancel();
    super.dispose();
  }

  Future<void> configure() async {
    final ws = ref.read(workspaceProvider).requireValue;
    final seconds = TextEditingController(
          text: (ws.clock.durationMs ~/ 1000).toString(),
        ),
        increment = TextEditingController(
          text: (ws.clock.incrementMs ~/ 1000).toString(),
        );
    var bank = ws.bankMode;
    final form = GlobalKey<FormState>();
    try {
      final accepted = await showFormDialog<bool>(
        context: context,
        builder: (dialog) => StatefulBuilder(
          builder: (context, set) => AlertDialog(
            title: Text(tr(context, 'Régler le temps', 'Configure time')),
            content: SizedBox(
              width: 400,
              child: Form(
                key: form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: seconds,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: tr(
                          context,
                          'Durée en secondes',
                          'Duration in seconds',
                        ),
                      ),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        return n == null || n < 1 || n > 86400
                            ? '1–86400'
                            : null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: increment,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: tr(
                          context,
                          'Incrément par tour (secondes)',
                          'Increment per turn (seconds)',
                        ),
                      ),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        return n == null || n < 0 || n > 600 ? '0–600' : null;
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        tr(context, 'Réserve par joueur', 'Bank per player'),
                      ),
                      subtitle: Text(
                        tr(
                          context,
                          'Sinon : durée fixe à chaque tour.',
                          'Otherwise: fixed time each turn.',
                        ),
                      ),
                      value: bank,
                      onChanged: (v) => set(() => bank = v),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialog, false),
                child: Text(tr(context, 'Annuler', 'Cancel')),
              ),
              FilledButton(
                onPressed: () {
                  if (form.currentState!.validate()) {
                    Navigator.pop(dialog, true);
                  }
                },
                child: Text(tr(context, 'Appliquer', 'Apply')),
              ),
            ],
          ),
        ),
      );
      if (accepted == true) {
        await ref
            .read(workspaceProvider.notifier)
            .configureClock(
              int.parse(seconds.text),
              int.parse(increment.text),
              bank,
            );
      }
    } finally {
      seconds.dispose();
      increment.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ws = ref.watch(workspaceProvider).requireValue,
        controller = ref.read(workspaceProvider.notifier),
        theme = Theme.of(context),
        remaining = ws.clock.remainingAt(controller.time.now);
    return DeckPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(context, 'UN TEMPS POUR RÉFLÉCHIR', 'TIME TO THINK'),
            style: const TextStyle(
              fontFamily: 'IBMPlexMono',
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ws.current == null
                ? tr(context, 'Minuteur libre', 'Quick timer')
                : ws.current!.players[ws.current!.activeIndex].name,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Semantics(
            liveRegion: remaining < 10000,
            label: tr(context, 'Temps restant', 'Time remaining'),
            child: Text(
              clockText(remaining),
              style: TextStyle(
                fontFamily: theme.extension<DeckStyle>()!.headingFont,
                fontSize: 64,
                height: 1.1,
                color: theme.extension<DeckStyle>()!.signal,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () => controller.toggleClock(),
                icon: Icon(ws.clock.isRunning ? Icons.pause : Icons.play_arrow),
                label: Text(
                  ws.clock.isRunning
                      ? tr(context, 'Pause', 'Pause')
                      : tr(context, 'Démarrer', 'Start'),
                ),
              ),
              IconButton(
                tooltip: tr(context, 'Réinitialiser', 'Reset'),
                onPressed: () => controller.clock(ws.clock.reset()),
                icon: const Icon(Icons.restart_alt),
              ),
              IconButton(
                tooltip: tr(context, 'Réglages du minuteur', 'Timer settings'),
                onPressed: configure,
                icon: const Icon(Icons.tune),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${ws.bankMode ? tr(context, 'Réserve par joueur', 'Player bank') : tr(context, 'Temps par tour', 'Time per turn')} · +${ws.clock.incrementMs ~/ 1000}s',
            style: theme.textTheme.bodySmall,
          ),
          if (ws.bankMode && ws.current != null) ...[
            const Divider(height: 32),
            for (final p in ws.current!.players)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(p.name)),
                    Text(
                      clockText(
                        p.id == ws.current!.players[ws.current!.activeIndex].id
                            ? remaining
                            : ws.banks[p.id] ?? ws.clock.durationMs,
                      ),
                      style: const TextStyle(fontFamily: 'IBMPlexMono'),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
