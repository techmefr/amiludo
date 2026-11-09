import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/intro/intro_backdrop_painter.dart';
import 'package:amiludo/layers/technical/Theme/components/intro/intro_mark.dart';
import 'package:amiludo/layers/technical/Theme/components/intro/intro_timeline.dart';
import 'package:amiludo/layers/technical/Theme/components/intro/intro_words.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const double _centerFactor = .42;

class IntroOverlay extends StatelessWidget {
  const IntroOverlay({
    super.key,
    required this.animation,
    required this.words,
    required this.skipLabel,
    required this.onSkip,
  });

  final Animation<double> animation;
  final List<String> words;
  final String skipLabel;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        onSkip();
        return KeyEventResult.handled;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onSkip,
        child: LayoutBuilder(
          builder: (context, c) {
            final mark = math.min(c.maxWidth, c.maxHeight) * .36;
            final top = c.maxHeight * _centerFactor;
            return Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: animation,
                    builder: (context, _) => ColoredBox(
                      color: scheme.surface.withValues(
                        alpha:
                            1 -
                            IntroTimeline.span(
                              animation.value,
                              IntroTimeline.zoomStart,
                              IntroTimeline.zoomEnd + 100,
                            ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ExcludeSemantics(
                    child: CustomPaint(
                      painter: IntroBackdropPainter(
                        animation: animation,
                        color: scheme.primary,
                        centerFactor: _centerFactor,
                        markSize: mark,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: (c.maxWidth - mark) / 2,
                  top: top - mark / 2,
                  width: mark,
                  height: mark,
                  child: IntroMark(
                    animation: animation,
                    size: mark,
                    travel: c.maxHeight,
                  ),
                ),
                Positioned(
                  left: Space.lg,
                  right: Space.lg,
                  top: top + mark / 2 + Space.xl,
                  child: IntroWords(animation: animation, words: words),
                ),
                Positioned(
                  top: MediaQuery.paddingOf(context).top + Space.lg,
                  right: Space.lg,
                  child: _SkipPill(
                    animation: animation,
                    label: skipLabel,
                    onTap: onSkip,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SkipPill extends StatelessWidget {
  const _SkipPill({
    required this.animation,
    required this.label,
    required this.onTap,
  });

  final Animation<double> animation;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
        opacity:
            IntroTimeline.span(animation.value, 200, 600) *
            (1 - IntroTimeline.span(animation.value, 3900, 4300)),
        child: child,
      ),
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        onTap: onTap,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: Targets.minimum),
            padding: const EdgeInsets.symmetric(horizontal: Space.xl),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.pill),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: .3),
              ),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
