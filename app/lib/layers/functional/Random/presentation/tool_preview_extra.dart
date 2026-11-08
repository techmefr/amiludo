import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

Widget _count(BuildContext context, Color ink, String text) => Center(
  child: Text(
    text,
    style: Numerals.instrument(
      Theme.of(context).textTheme.displaySmall,
    )?.copyWith(color: ink),
  ),
);

Widget _bars(Color accent, Color ink, double t, List<double> heights) => Row(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    for (final h in heights)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.xs),
        child: Container(
          width: 28,
          height: 70 * h * t,
          decoration: BoxDecoration(
            color: h == 1 ? accent : ink.withValues(alpha: .35),
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
        ),
      ),
  ],
);

Widget _dots(Color accent, Color ink, double t) => Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    for (var i = 0; i < 4; i++)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.xs),
        child: AnimatedContainer(
          duration: Motion.fast,
          width: i == (t * 3).round() ? 30 : 18,
          height: i == (t * 3).round() ? 30 : 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i <= (t * 3).round() ? accent : ink.withValues(alpha: .25),
          ),
        ),
      ),
  ],
);

Widget _order(Color accent, Color ink, double t) {
  final turn = (t * 3).floor().clamp(0, 2);
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var i = 0; i < 3; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Space.xs),
          child: AnimatedContainer(
            duration: Motion.fast,
            width: i == turn ? 110 : 90,
            height: 18,
            decoration: BoxDecoration(
              color: i == turn ? accent : ink.withValues(alpha: .22),
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
          ),
        ),
    ],
  );
}

Widget _stack(Color accent, Color ink, double t) => Center(
  child: SizedBox(
    width: 120,
    height: 90,
    child: Stack(
      alignment: Alignment.center,
      children: [
        for (var i = 2; i >= 0; i--)
          Transform.translate(
            offset: Offset(i * 10.0 * t, -i * 8.0 * t),
            child: Container(
              width: 70,
              height: 56,
              decoration: BoxDecoration(
                color: i == 0 ? accent : ink.withValues(alpha: .25),
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
            ),
          ),
      ],
    ),
  ),
);

Widget _chain(Color accent, Color ink, double t) {
  final active = (t * 3).floor().clamp(0, 2);
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var i = 0; i < 3; i++) ...[
        if (i > 0)
          Container(width: 22, height: 3, color: ink.withValues(alpha: .35)),
        AnimatedContainer(
          duration: Motion.fast,
          width: i == active ? 34 : 24,
          height: i == active ? 34 : 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == active ? accent : ink.withValues(alpha: .25),
          ),
        ),
      ],
    ],
  );
}

Widget? extraPreview(
  BuildContext context,
  String id,
  Color accent,
  Color ink,
  double t,
) => switch (id) {
  'ranking' => _bars(accent, ink, t, const [.7, 1, .5]),
  'stats' => _bars(accent, ink, t, const [.4, .6, 1, .8]),
  'turns' => _dots(accent, ink, t),
  'bank' => _count(context, ink, '${1500 + (200 * t).round()}'),
  'auction' => _count(context, ink, '${(35 * t).round()}'),
  'combat' => _order(accent, ink, t),
  'gmtables' => _bars(accent, ink, t, const [.5, 1, .7, .35]),
  'scenes' => _chain(accent, ink, t),
  'bestiary' => _stack(accent, ink, t),
  'clocks' => Center(
    child: SizedBox.square(
      dimension: 76,
      child: CircularProgressIndicator(
        value: .75 * t,
        strokeWidth: 12,
        color: accent,
        backgroundColor: ink.withValues(alpha: .2),
      ),
    ),
  ),
  _ => null,
};
