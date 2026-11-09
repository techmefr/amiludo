import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/intro/intro_timeline.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class IntroWords extends StatelessWidget {
  const IntroWords({super.key, required this.animation, required this.words});

  final Animation<double> animation;
  final List<String> words;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: FontWeight.w800,
    );
    final slot = (style?.fontSize ?? TypeScale.headline) * 1.5;
    return Semantics(
      label: words.join(' '),
      excludeSemantics: true,
      child: SizedBox(
        height: slot,
        child: ClipRect(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final t = animation.value;
              final gone =
                  1 -
                  IntroTimeline.span(
                    t,
                    IntroTimeline.zoomStart - 100,
                    IntroTimeline.zoomStart + 200,
                  );
              return Stack(
                alignment: Alignment.center,
                children: [
                  for (var i = 0; i < words.length; i++)
                    _line(i, t, slot, gone, style),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _line(int i, double t, double slot, double gone, TextStyle? style) {
    final enterAt = IntroTimeline.wordEnterStart(i);
    final exitAt = IntroTimeline.wordExitStart(i, words.length);
    final enter = IntroTimeline.span(
      t,
      enterAt,
      enterAt + IntroTimeline.wordEnter,
      IntroTimeline.expoOut,
    );
    final exit = IntroTimeline.span(
      t,
      exitAt,
      exitAt + IntroTimeline.wordExit,
      IntroTimeline.expoIn,
    );
    return Opacity(
      opacity: enter * (1 - exit) * gone,
      child: Transform.translate(
        offset: Offset(0, (1 - enter) * slot - exit * slot),
        child: Text(words[i], style: style, textAlign: TextAlign.center),
      ),
    );
  }
}
