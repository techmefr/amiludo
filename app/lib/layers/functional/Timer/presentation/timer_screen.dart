import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Timer/presentation/timer_panel.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DeckHeading(
        eyebrow: 'TEMPO / TIMER',
        title: tr(context, 'Un temps pour jouer', 'Time to play'),
      ),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: const TimerPanel(),
      ),
    ],
  );
}
