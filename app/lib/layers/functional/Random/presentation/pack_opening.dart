import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/presentation/card_face.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/technical/Theme/components/pack/pack_idle.dart';
import 'package:amiludo/layers/technical/Theme/components/pack/pack_stage.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_back.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_face.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
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
        PackIdle(
          width: 96,
          label: context.l10n.randomTapPackToOpen,
          onTap: onOpen,
        ),
        const SizedBox(height: Space.md),
        Text(
          category.name,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Space.sm),
        Text(context.l10n.randomCardsToReveal(category.draw)),
        const SizedBox(height: Space.xl),
        FilledButton(
          onPressed: onOpen,
          child: Text(context.l10n.randomOpenThePack(category.name)),
        ),
      ],
    ),
  );
}

double packRarity(CharacterCard card) =>
    (card.name.codeUnits.fold<int>(0, (a, b) => a + b) % 100) / 100;

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
  bool ceremony = true;

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
              onPressed: () => setState(() {
                ceremony = false;
                controller.value = 1;
              }),
              child: Text(context.l10n.randomRevealAll),
            ),
          ),
        if (ceremony && !MediaQuery.disableAnimationsOf(context))
          Padding(
            padding: const EdgeInsets.only(bottom: Space.lg),
            child: PackStage(
              autoOpen: true,
              rarities: [for (final c in widget.cards) packRarity(c)],
              packLabel: context.l10n.randomTapPackToOpen,
              cardLabel: context.l10n.randomTapCardToReveal,
              onDone: () => setState(() => ceremony = false),
              faceBuilder: (i, width) => TarotFace(
                title: widget.cards[i].name,
                description: widget.cards[i].description,
                number: i + 1,
                width: width,
              ),
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
  Widget build(BuildContext context) => const AspectRatio(
    aspectRatio: 5 / 7,
    child: FittedBox(child: TarotBack(width: 100)),
  );
}
