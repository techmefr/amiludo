import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';

class CardFace extends StatelessWidget {
  const CardFace({
    super.key,
    required this.card,
    required this.type,
    this.selected = false,
  });

  final CharacterCard card;
  final String type;
  final bool selected;

  Widget art() {
    final image = card.image;
    const fallback = Center(child: DeckIcon(Icons.style_outlined, size: 56));
    if (image == null) return fallback;
    return Image.asset(
      'assets/$image.png',
      fit: BoxFit.cover,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => fallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$type. ${card.name}. ${card.description}',
      selected: selected,
      child: ExcludeSemantics(
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              width: selected ? 3 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(aspectRatio: 1, child: art()),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type, style: theme.textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Text(card.name, style: theme.textTheme.titleMedium),
                    if (card.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        card.description,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
