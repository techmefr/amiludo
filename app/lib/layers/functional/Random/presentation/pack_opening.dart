import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/presentation/card_face.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class ClosedPack extends StatelessWidget {
  const ClosedPack({super.key, required this.category, required this.onOpen});

  final CreationCategory category;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => DeckPanel(
    highlight: true,
    child: Column(
      children: [
        const DeckIcon(Icons.style_outlined, size: 72),
        const SizedBox(height: 12),
        Text(
          category.name,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(context.l10n.randomCardsToReveal(category.draw)),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: onOpen,
          child: Text(context.l10n.randomOpenThePack(category.name)),
        ),
      ],
    ),
  );
}

class PackReveal extends StatefulWidget {
  const PackReveal({
    super.key,
    required this.type,
    required this.cards,
    required this.selected,
    required this.keepMax,
    required this.onToggle,
  });

  final String type;
  final List<CharacterCard> cards;
  final Set<int> selected;
  final int keepMax;
  final void Function(int index) onToggle;

  @override
  State<PackReveal> createState() => _PackRevealState();
}

class _PackRevealState extends State<PackReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 450 * widget.cards.length),
  );
  bool started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (started) return;
    started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.value = 1;
    } else {
      controller.forward();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  double progress(int i) {
    final n = widget.cards.length;
    return Interval(
      i / n,
      (i + 1) / n,
      curve: Curves.easeOut,
    ).transform(controller.value);
  }

  bool canSelect(int i) =>
      widget.selected.contains(i) || widget.selected.length < widget.keepMax;

  Widget card(int i) {
    final t = progress(i);
    final selectable = canSelect(i);
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY((1 - t) * math.pi),
      child: t >= 0.5
          ? Semantics(
              button: true,
              enabled: selectable,
              onTap: selectable ? () => widget.onToggle(i) : null,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: selectable ? () => widget.onToggle(i) : null,
                child: CardFace(
                  card: widget.cards[i],
                  type: widget.type,
                  selected: widget.selected.contains(i),
                ),
              ),
            )
          : const _CardBack(),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (_, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.value < 1)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => controller.value = 1,
              child: Text(context.l10n.randomRevealAll),
            ),
          ),
        ResponsiveGrid(
          minimumWidth: 220,
          children: [for (var i = 0; i < widget.cards.length; i++) card(i)],
        ),
      ],
    ),
  );
}

class _CardBack extends StatelessWidget {
  const _CardBack();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AspectRatio(
      aspectRatio: 5 / 7,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: DeckIcon(Icons.style_outlined, size: 56)),
      ),
    ),
  );
}
