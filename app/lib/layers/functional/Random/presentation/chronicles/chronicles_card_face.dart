import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_card.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/card_painter.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const cardAspect = 0.7;

class ChroniclesCardFace extends StatefulWidget {
  const ChroniclesCardFace({
    super.key,
    required this.card,
    required this.score,
    required this.label,
    required this.rarityName,
    this.destiny = false,
  });
  final ChroniclesCard card;
  final int score;
  final String label, rarityName;
  final bool destiny;

  @override
  State<ChroniclesCardFace> createState() => _ChroniclesCardFaceState();
}

class _ChroniclesCardFaceState extends State<ChroniclesCardFace>
    with SingleTickerProviderStateMixin {
  late final AnimationController shimmer = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (still || widget.score < hologramFrom) {
      shimmer.stop();
    } else if (!shimmer.isAnimating) {
      shimmer.forward(from: 0);
    }
  }

  @override
  void dispose() {
    shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = widget.card;
    return Semantics(
      label: '${widget.label}. ${c.name}. ${widget.rarityName}. ${c.text}',
      child: ExcludeSemantics(
        child: AspectRatio(
          aspectRatio: cardAspect,
          child: AnimatedBuilder(
            animation: shimmer,
            builder: (context, child) => CustomPaint(
              painter: ChroniclesCardPainter(
                id: c.id,
                score: widget.score,
                surface: theme.colorScheme.surface,
                phase: shimmer.status == AnimationStatus.dismissed
                    ? 0.5
                    : shimmer.value,
              ),
              child: child,
            ),
            child: Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label, style: theme.textTheme.labelSmall),
                  const Spacer(flex: 5),
                  Text(c.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: Space.xs),
                  Expanded(
                    flex: 4,
                    child: Text(
                      c.text,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Text(widget.rarityName, style: theme.textTheme.labelSmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
