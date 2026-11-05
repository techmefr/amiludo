import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Timer/presentation/timer_panel.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DeckHeading(
        eyebrow: 'TEMPO / TIMER',
        title: context.l10n.timerTimeToPlay,
      ),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: const TimerPanel(),
      ),
    ],
  );
}
