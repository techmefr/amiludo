import 'package:flutter/material.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/tray_result.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

String trayResultLabel(AppLocalizations l, TrayResultMode mode) =>
    switch (mode) {
      TrayResultMode.none => l.diceResultNone,
      TrayResultMode.list => l.diceResultList,
      TrayResultMode.combined => l.diceResultCombined,
      TrayResultMode.sum => l.diceResultSum,
      TrayResultMode.best => l.diceResultBest,
      TrayResultMode.worst => l.diceResultWorst,
      TrayResultMode.dropWorst => l.diceResultDropWorst,
      TrayResultMode.dropBest => l.diceResultDropBest,
      TrayResultMode.middle => l.diceResultMiddle,
      TrayResultMode.average => l.diceResultAverage,
      TrayResultMode.oddEven => l.diceResultOddEven,
    };

class TrayResultView extends StatelessWidget {
  const TrayResultView({
    super.key,
    required this.session,
    this.mode = TrayResultMode.sum,
    this.onMode,
  });
  final DiceTraySession session;
  final TrayResultMode mode;
  final ValueChanged<TrayResultMode>? onMode;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final text = trayResultText(
      mode,
      session,
      oddEven: l.diceResultOddEvenCount,
    );
    final listed = mode != TrayResultMode.list && mode != TrayResultMode.none;
    return Column(
      children: [
        Semantics(
          liveRegion: true,
          child: TweenAnimationBuilder<double>(
            key: ValueKey(text),
            tween: Tween(
              begin: MediaQuery.disableAnimationsOf(context) ? 1 : 0.8,
              end: 1,
            ),
            duration: Motion.slow,
            curve: Curves.easeOutBack,
            builder: (_, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Text(
              session.thrown ? text : '–',
              style: theme.textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (session.thrown && listed)
          Text(
            [
              for (var i = 0; i < session.values.length; i++)
                session.settings.dice[i].faceLabel(session.values[i]),
            ].join(' · '),
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        if (onMode != null)
          PopupMenuButton<TrayResultMode>(
            tooltip: l.diceResultMode,
            initialValue: mode,
            onSelected: onMode,
            itemBuilder: (_) => [
              for (final m in TrayResultMode.values)
                PopupMenuItem(value: m, child: Text(trayResultLabel(l, m))),
            ],
            child: Padding(
              padding: const EdgeInsets.all(Space.sm),
              child: Text(
                '${l.diceResultMode} · ${trayResultLabel(l, mode)}',
                style: theme.textTheme.labelLarge,
              ),
            ),
          ),
      ],
    );
  }
}
