import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/card_deck.dart';
import 'package:amiludo/layers/functional/Random/presentation/deck_face.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/playing_card.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class DeckTool extends StatefulWidget {
  const DeckTool({super.key, this.random});
  final Random? random;

  @override
  State<DeckTool> createState() => _DeckToolState();
}

class _DeckToolState extends State<DeckTool> {
  final tool = toolThemeFor('deck');
  final _custom = TextEditingController();
  late final Random _random = widget.random ?? Random.secure();
  late CardDeck deck = CardDeck.shuffled(standardCards(), _random);
  bool own = false;

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {
    deck = CardDeck.shuffled(
      own ? parseCards(_custom.text) : standardCards(),
      _random,
    );
  });

  void _apply(CardDeck next) {
    tool.signal();
    setState(() => deck = next);
  }

  Widget _flip(Widget child, Animation<double> animation) => AnimatedBuilder(
    animation: animation,
    child: child,
    builder: (context, child) => Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, .001)
        ..rotateY((1 - animation.value) * pi / 2),
      child: child,
    ),
  );

  Widget _top(double width) {
    final card = deck.top;
    return AnimatedSwitcher(
      duration: tool.duration(context),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: _flip,
      child: card == null
          ? Semantics(
              key: const ValueKey('face-down'),
              label: context.l10n.deckFaceDown,
              excludeSemantics: true,
              child: PlayingCard(faceDown: true, width: width),
            )
          : DeckFace(
              key: ValueKey('${deck.hand.length}-$card'),
              card: card,
              width: width,
            ),
    );
  }

  Widget _controls() {
    final l = context.l10n;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: Space.md,
      runSpacing: Space.md,
      children: [
        FilledButton.icon(
          onPressed: deck.isEmpty ? null : () => _apply(deck.draw()),
          icon: const DeckIcon(Icons.style_outlined),
          label: Text(l.deckDraw),
        ),
        OutlinedButton.icon(
          onPressed: deck.isEmpty
              ? null
              : () => _apply(deck.reshuffled(_random)),
          icon: const DeckIcon(Icons.swap_vert),
          label: Text(l.deckShuffle),
        ),
        OutlinedButton.icon(
          onPressed: deck.discard.isEmpty
              ? null
              : () => _apply(deck.recycle(_random)),
          icon: const DeckIcon(Icons.refresh),
          label: Text(l.deckRecycle),
        ),
        TextButton(
          onPressed: deck.hand.isEmpty
              ? null
              : () => _apply(deck.discardHand()),
          child: Text(l.deckDiscardHand),
        ),
      ],
    );
  }

  Widget _hand() {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.deckHandTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: Space.sm),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (var i = 0; i < deck.hand.length; i++)
              Tooltip(
                message: l.deckDiscardCard(deck.hand[i]),
                child: InkWell(
                  borderRadius: BorderRadius.circular(Radii.md),
                  onTap: () => _apply(deck.discardAt(i)),
                  child: DeckFace(card: deck.hand[i], width: 64),
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final width = (MediaQuery.sizeOf(context).width * .5).clamp(140.0, 220.0);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l.deckStandard)),
                ButtonSegment(value: true, label: Text(l.deckCustom)),
              ],
              selected: {own},
              onSelectionChanged: (s) {
                own = s.first;
                _rebuild();
              },
            ),
            if (own) ...[
              const SizedBox(height: Space.lg),
              TextField(
                controller: _custom,
                minLines: 3,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: l.deckCustomLabel,
                  helperText: l.deckCustomHelper,
                ),
                onChanged: (_) => _rebuild(),
              ),
            ],
            const SizedBox(height: Space.xl),
            Center(child: _top(width)),
            const SizedBox(height: Space.lg),
            Semantics(
              liveRegion: true,
              child: Text(
                deck.isEmpty
                    ? l.deckEmpty
                    : '${l.deckRemaining(deck.pile.length)} · '
                          '${l.deckDiscardCount(deck.discard.length)}',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: Space.lg),
            _controls(),
            if (deck.hand.isNotEmpty) ...[
              const SizedBox(height: Space.xl),
              _hand(),
            ],
          ],
        ),
      ),
    );
  }
}
