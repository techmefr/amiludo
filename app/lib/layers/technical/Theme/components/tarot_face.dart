import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/tarot_style.dart';

class TarotFace extends StatelessWidget {
  const TarotFace({
    super.key,
    required this.title,
    this.number,
    this.description,
    this.art,
    this.style = TarotStyle.nightGold,
    this.width = 160,
  });
  final String title;
  final int? number;
  final String? description;
  final Widget? art;
  final TarotStyle style;
  final double width;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final ink = style.ink;
    final frame = style == TarotStyle.ivoryInk ? style.ink : style.line;
    return Semantics(
      container: true,
      label: [
        ?number == null ? null : romanNumeral(number!),
        title,
        ?description,
      ].join(', '),
      excludeSemantics: true,
      child: SizedBox(
        width: width,
        height: width / tarotRatio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: style.paper,
            borderRadius: BorderRadius.circular(width * .06),
            border: Border.all(color: frame, width: width * .014),
            boxShadow: [
              BoxShadow(
                color: style.deep.withValues(alpha: .4),
                blurRadius: width * .1,
                offset: Offset(0, width * .04),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(width * .07),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: frame.withValues(alpha: .7),
                  width: width * .006,
                ),
                borderRadius: BorderRadius.circular(width * .03),
              ),
              child: Padding(
                padding: EdgeInsets.all(width * .04),
                child: Column(
                  children: [
                    if (number != null)
                      Text(
                        romanNumeral(number!),
                        style: text.titleMedium?.copyWith(
                          color: ink,
                          fontSize: width * .1,
                          letterSpacing: width * .02,
                        ),
                      ),
                    Expanded(
                      child: Center(
                        child:
                            art ??
                            Icon(
                              Icons.auto_awesome,
                              size: width * .4,
                              color: ink.withValues(alpha: .75),
                            ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: style.bandColor,
                        borderRadius: BorderRadius.circular(width * .02),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * .04,
                          vertical: width * .025,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: text.titleMedium?.copyWith(
                                color: style.bandInk,
                                fontSize: width * .09,
                                fontWeight: FontWeight.w700,
                                letterSpacing: width * .008,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (description != null)
                      Padding(
                        padding: EdgeInsets.only(top: width * .03),
                        child: Text(
                          description!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: text.bodySmall?.copyWith(
                            color: ink,
                            fontSize: width * .075,
                            height: 1.2,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
