import 'dart:async';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Feedback/device_feedback.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/deck_theme.dart';
import 'package:amiludo/layers/functional/Timer/presentation/cubit/timer_cubit.dart';
import 'package:amiludo/layers/functional/Timer/domain/entities/game_clock.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class TimerPanel extends StatefulWidget {
  const TimerPanel({super.key});
  @override
  State<TimerPanel> createState() => _TimerPanelState();
}

class _TimerPanelState extends State<TimerPanel> {
  Timer? ticker;
  bool alerted = false;
  @override
  void initState() {
    super.initState();
    ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) return;
      final controller = context.read<TimerCubit>(), ws = controller.state;
      if (ws.clock.isRunning &&
          ws.clock.remainingAt(controller.time.now) == 0 &&
          !alerted) {
        alerted = true;
        controller.setClock(ws.clock.pause(controller.time.now));
        DeviceFeedback.expired(
          sound: ws.appearance.sound,
          haptics: ws.appearance.haptics,
        );
        notify(context, context.l10n.timerTimeIsUpPassThe);
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
    final ws = context.read<TimerCubit>().state;
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
            title: Text(context.l10n.timerConfigureTime),
            content: SizedBox(
              width: 400,
              child: Form(
                key: form,
                child: _TimerSettingsFields(
                  seconds: seconds,
                  increment: increment,
                  bank: bank,
                  onBankChanged: (v) => set(() => bank = v),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialog, false),
                child: Text(context.l10n.themeCancel),
              ),
              FilledButton(
                onPressed: () {
                  if (form.currentState!.validate()) {
                    Navigator.pop(dialog, true);
                  }
                },
                child: Text(context.l10n.timerApply),
              ),
            ],
          ),
        ),
      );
      if (accepted == true && mounted) {
        await context.read<TimerCubit>().configure(
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
    final ws = context.watch<TimerCubit>().state,
        controller = context.read<TimerCubit>(),
        theme = Theme.of(context),
        remaining = ws.clock.remainingAt(controller.time.now);
    return DeckPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.timerTimeToThink,
            style: const TextStyle(
              fontFamily: 'IBMPlexMono',
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ws.current == null
                ? context.l10n.timerQuickTimer
                : ws.current!.players[ws.current!.activeIndex].name,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          _ClockReadout(remaining: remaining),
          const SizedBox(height: 24),
          _TimerControls(
            running: ws.clock.isRunning,
            onToggle: () => controller.toggle(),
            onReset: () => controller.setClock(ws.clock.reset()),
            onConfigure: configure,
          ),
          const SizedBox(height: 16),
          Text(
            '${ws.bankMode ? context.l10n.timerPlayerBank : context.l10n.timerTimePerTurn} · +${ws.clock.incrementMs ~/ 1000}s',
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

class _ClockReadout extends StatelessWidget {
  const _ClockReadout({required this.remaining});
  final int remaining;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: remaining < 10000,
      label: context.l10n.timerTimeRemaining,
      child: Text(
        clockText(remaining),
        style: TextStyle(
          fontFamily: theme.extension<DeckStyle>()!.headingFont,
          fontSize: 64,
          height: 1.1,
          color: theme.extension<DeckStyle>()!.signal,
        ),
      ),
    );
  }
}

class _TimerControls extends StatelessWidget {
  const _TimerControls({
    required this.running,
    required this.onToggle,
    required this.onReset,
    required this.onConfigure,
  });
  final bool running;
  final VoidCallback onToggle, onReset, onConfigure;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 12,
    children: [
      FilledButton.icon(
        onPressed: onToggle,
        icon: DeckIcon(running ? Icons.pause : Icons.play_arrow),
        label: Text(
          running ? context.l10n.timerPause : context.l10n.timerStart,
        ),
      ),
      IconButton(
        tooltip: context.l10n.appearanceReset,
        onPressed: onReset,
        icon: const DeckIcon(Icons.restart_alt),
      ),
      IconButton(
        tooltip: context.l10n.timerTimerSettings,
        onPressed: onConfigure,
        icon: const DeckIcon(Icons.tune),
      ),
    ],
  );
}

class _TimerSettingsFields extends StatelessWidget {
  const _TimerSettingsFields({
    required this.seconds,
    required this.increment,
    required this.bank,
    required this.onBankChanged,
  });
  final TextEditingController seconds, increment;
  final bool bank;
  final ValueChanged<bool> onBankChanged;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextFormField(
        controller: seconds,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: context.l10n.timerDurationInSeconds,
        ),
        validator: (v) {
          final n = int.tryParse(v ?? '');
          return n == null || n < 1 || n > 86400 ? '1–86400' : null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: increment,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: context.l10n.timerIncrementPerTurnSeconds,
        ),
        validator: (v) {
          final n = int.tryParse(v ?? '');
          return n == null || n < 0 || n > 600 ? '0–600' : null;
        },
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(context.l10n.timerBankPerPlayer),
        subtitle: Text(context.l10n.timerOtherwiseFixedTimeEachTurn),
        value: bank,
        onChanged: onBankChanged,
      ),
    ],
  );
}
