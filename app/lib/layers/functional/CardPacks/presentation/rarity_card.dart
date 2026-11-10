import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/CardPacks/domain/entities/player_packs.dart';
import 'package:amiludo/layers/functional/CardPacks/presentation/card_pack_labels.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/holo_foil.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_face.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class RarityCard extends StatelessWidget {
  const RarityCard({
    super.key,
    required this.dealt,
    required this.category,
    required this.number,
    this.kept,
    this.onTap,
    this.width = 150,
  });

  final DealtCard dealt;
  final String category;
  final int number;
  final bool? kept;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rarity = context.rarityLabel(dealt.rarity);
    final state = kept == null
        ? null
        : kept!
        ? context.l10n.cpKeptState
        : context.l10n.cpDiscardedState;
    final face = TarotFace(
      title: dealt.card.name,
      description: dealt.card.description,
      number: number,
      width: width,
    );
    return Semantics(
      button: onTap != null,
      selected: kept ?? false,
      label: [category, dealt.card.name, rarity, ?state].join('. '),
      child: ExcludeSemantics(
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.lg),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Targets.minimum),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Radii.lg),
                    border: Border.all(
                      color: kept == true
                          ? scheme.primary
                          : const Color(0x00000000),
                      width: 3,
                    ),
                  ),
                  child: dealt.rarity.foil ? HoloFoil(child: face) : face,
                ),
                const SizedBox(height: Space.xs),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: Space.xs,
                  children: [
                    Icon(rarityIcon(dealt.rarity), size: 16),
                    Text(
                      state == null ? rarity : '$rarity · $state',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
