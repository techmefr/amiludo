import 'dart:async';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/stone_slab.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

const _bidSteps = [1, 5, 10, 50];
const _countdown = 15;

class AuctionTool extends StatefulWidget {
  const AuctionTool({super.key, required this.names});
  final List<String> names;

  @override
  State<AuctionTool> createState() => _AuctionToolState();
}

class _AuctionToolState extends State<AuctionTool> {
  int bid = 0, left = _countdown;
  int? bidder, buyer;
  Timer? ticker;
  final tool = toolThemeFor('auction');

  @override
  void dispose() {
    ticker?.cancel();
    super.dispose();
  }

  void _raise(int step) {
    if (bidder == null || buyer != null) return;
    tool.signal();
    ticker?.cancel();
    ticker = Timer.periodic(const Duration(seconds: 1), _tick);
    setState(() {
      bid += step;
      left = _countdown;
    });
  }

  void _tick(Timer timer) {
    if (left <= 1) {
      timer.cancel();
      setState(() {
        left = 0;
        buyer = bidder;
      });
      return;
    }
    setState(() => left--);
  }

  void _reset() {
    ticker?.cancel();
    setState(() {
      bid = 0;
      left = _countdown;
      bidder = null;
      buyer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final sold = buyer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StoneSlab(
          accent: tool.accent,
          halo: sold == null ? null : StonePalette.gold,
          child: Padding(
            padding: const EdgeInsets.all(Space.xl),
            child: Semantics(
              liveRegion: true,
              child: Column(
                children: [
                  Text('$bid', style: stoneNumerals(TypeScale.display * 2)),
                  Text(
                    sold != null
                        ? l.auctionSold(widget.names[sold], bid)
                        : (bidder == null
                              ? l.auctionPickBidder
                              : l.auctionLeft(left)),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: StonePalette.cream,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: Space.lg),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final (i, name) in widget.names.indexed)
              ChoiceChip(
                label: Text(name),
                selected: bidder == i,
                onSelected: sold != null
                    ? null
                    : (_) => setState(() => bidder = i),
              ),
          ],
        ),
        const SizedBox(height: Space.lg),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final step in _bidSteps)
              FilledButton(
                onPressed: bidder == null || sold != null
                    ? null
                    : () => _raise(step),
                child: Text('+$step'),
              ),
            TextButton(onPressed: _reset, child: Text(l.appearanceReset)),
          ],
        ),
      ],
    );
  }
}
