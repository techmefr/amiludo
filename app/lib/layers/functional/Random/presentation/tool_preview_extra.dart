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
