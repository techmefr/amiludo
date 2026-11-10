import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/CardPacks/domain/entities/player_packs.dart';
import 'package:amiludo/layers/functional/CardPacks/presentation/card_pack_labels.dart';
import 'package:amiludo/layers/functional/CardPacks/presentation/rarity_card.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/pack/pack_idle.dart';
import 'package:amiludo/layers/technical/Theme/components/pack/pack_stage.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class SealedPackView extends StatefulWidget {
  const SealedPackView({super.key, required this.pack, required this.onOpened});

  final SealedPack pack;
  final VoidCallback onOpened;

  @override
  State<SealedPackView> createState() => _SealedPackViewState();
}

class _SealedPackViewState extends State<SealedPackView> {
  bool opening = false;

  void begin() {
    if (MediaQuery.disableAnimationsOf(context)) {
      widget.onOpened();
    } else {
      setState(() => opening = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pack = widget.pack;
    if (opening) {
      return PackStage(
        autoOpen: true,
        rarities: [for (final c in pack.cards) rarityWeight(c.rarity)],
        packLabel: context.l10n.cpOpenPack(pack.category),
        cardLabel: context.l10n.cpTapCard,
        onDone: widget.onOpened,
        faceBuilder: (i, width) => RarityCard(
          dealt: pack.cards[i],
          category: pack.category,
          number: i + 1,
          width: width,
        ),
      );
    }
    return Column(
      children: [
        PackIdle(
          width: 96,
          label: context.l10n.cpOpenPack(pack.category),
          onTap: begin,
        ),
        const SizedBox(height: Space.md),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(Targets.minimum, Targets.minimum),
          ),
          onPressed: begin,
          child: Text(context.l10n.cpOpenPack(pack.category)),
        ),
      ],
    );
  }
}
