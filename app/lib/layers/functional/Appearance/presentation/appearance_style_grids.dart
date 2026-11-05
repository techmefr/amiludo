import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Theme/deck_theme.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/functional/Appearance/presentation/cubit/appearance_cubit.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class AppearanceSkinGrid extends StatelessWidget {
  const AppearanceSkinGrid({
    super.key,
    required this.appearance,
    required this.controller,
  });
  final Appearance appearance;
  final AppearanceCubit controller;

  static const _skins = [
    ('play', 'Playroom', 'Des couleurs, des cartes et l’envie de jouer.'),
    ('cyber', 'CYBERDECK', 'Noir, néon, angles biseautés.'),
    ('orbital', 'ORBITAL 77', 'Ivoire, ambre, instruments rétro.'),
    ('paper', 'CARNET', 'Doux, coloré, esprit papier.'),
  ];

  Appearance _withSkin(String id) => appearance.copyWith(
    skin: id,
    palette: id == 'play'
        ? 'play'
        : id == 'cyber'
        ? 'acid'
        : id == 'orbital'
        ? 'amber'
        : 'lichen',
    mode: id == 'cyber' ? 'dark' : 'light',
    shape: id == 'play'
        ? 'round'
        : id == 'cyber'
        ? 'cut'
        : id == 'orbital'
        ? 'square'
        : 'soft',
    font: id == 'play'
        ? 'LilGrotesk'
        : id == 'orbital'
        ? 'Rajdhani'
        : id == 'paper'
        ? 'DMSans'
        : 'SpaceGrotesk',
  );

  @override
  Widget build(BuildContext context) {
    return ResponsiveGrid(
      minimumWidth: 200,
      children: [
        for (final (id, name, desc) in _skins)
          DeckPanel(
            highlight: appearance.skin == id,
            padding: 20,
            child: InkWell(
              onTap: () => controller.change(_withSkin(id)),
              child: _SkinCard(
                id: id,
                name: name,
                desc: desc,
                selected: appearance.skin == id,
              ),
            ),
          ),
      ],
    );
  }
}

class _SkinCard extends StatelessWidget {
  const _SkinCard({
    required this.id,
    required this.name,
    required this.desc,
    required this.selected,
  });
  final String id, name, desc;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeckIcon(
          id == 'cyber'
              ? Icons.hexagon_outlined
              : id == 'orbital'
              ? Icons.radar
              : Icons.auto_stories_outlined,
          size: 36,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(name, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(desc),
        const SizedBox(height: 12),
        Text(
          selected
              ? '✓ ${context.l10n.appearanceSelected}'
              : context.l10n.appearanceChooseThisWorld,
        ),
      ],
    );
  }
}

class AppearancePaletteGrid extends StatelessWidget {
  const AppearancePaletteGrid({
    super.key,
    required this.appearance,
    required this.controller,
  });
  final Appearance appearance;
  final AppearanceCubit controller;
  @override
  Widget build(BuildContext context) {
    final a = appearance;
    return ResponsiveGrid(
      minimumWidth: 180,
      children: DeckPalette.values.entries.map((entry) {
        final p = entry.value;
        return DeckPanel(
          highlight: a.palette == entry.key,
          padding: 16,
          child: InkWell(
            onTap: () => controller.change(a.copyWith(palette: entry.key)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children:
                      [p.darkBackground, p.darkHero, p.darkAccent, p.signal]
                          .map(
                            (c) => Expanded(
                              child: Container(height: 32, color: Color(c)),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 12),
                Text('${p.name}${a.palette == entry.key ? ' ✓' : ''}'),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class AppearanceFontGrid extends StatelessWidget {
  const AppearanceFontGrid({
    super.key,
    required this.appearance,
    required this.controller,
  });
  final Appearance appearance;
  final AppearanceCubit controller;
  @override
  Widget build(BuildContext context) {
    return ResponsiveGrid(
      minimumWidth: 220,
      children: Appearance.fonts
          .map(
            (font) => DeckPanel(
              highlight: appearance.font == font,
              padding: 20,
              child: InkWell(
                onTap: () => controller.change(appearance.copyWith(font: font)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      font,
                      style: TextStyle(fontFamily: font, fontSize: 22),
                    ),
                    const SizedBox(height: 8),
                    Text('Aa / 0123456789', style: TextStyle(fontFamily: font)),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
