import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Theme/components/aura/aura_preview.dart';
import 'package:amiludo/layers/technical/Theme/deck_theme.dart';
import 'package:amiludo/layers/technical/Theme/components/hud_bar.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/functional/Appearance/presentation/cubit/appearance_cubit.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';

class AppearanceSkinGrid extends StatelessWidget {
  const AppearanceSkinGrid({
    super.key,
    required this.appearance,
    required this.controller,
  });
  final Appearance appearance;
  final AppearanceCubit controller;

  static const _presets = {
    'clean': ('clean', 'system', 'round', 'System'),
    'play': ('play', 'light', 'round', 'LilGrotesk'),
    'cyber': ('acid', 'dark', 'cut', 'SpaceGrotesk'),
    'orbital': ('amber', 'light', 'square', 'Rajdhani'),
    'paper': ('lichen', 'light', 'soft', 'DMSans'),
    'game': ('gold', 'dark', 'square', 'Rajdhani'),
  };

  ThemeData _preview(BuildContext context, String id) {
    final next = _withSkin(id);
    final current = Theme.of(context).brightness;
    return deckTheme(next, switch (next.mode) {
      'dark' => Brightness.dark,
      'light' => Brightness.light,
      _ => current,
    });
  }

  Appearance _withSkin(String id) {
    final (palette, mode, shape, font) = _presets[id]!;
    return appearance.copyWith(
      skin: id,
      palette: palette,
      mode: mode,
      shape: shape,
      font: font,
    );
  }

  @override
  Widget build(BuildContext context) {
    final skins = [
      (
        'clean',
        context.l10n.appearanceSkinCleanName,
        context.l10n.appearanceSkinCleanDesc,
      ),
      ('play', 'Playroom', 'Des couleurs, des cartes et l’envie de jouer.'),
      ('cyber', 'CYBERDECK', 'Noir, néon, angles biseautés.'),
      ('orbital', 'ORBITAL 77', 'Ivoire, ambre, instruments rétro.'),
      ('paper', 'CARNET', 'Doux, coloré, esprit papier.'),
      (
        'game',
        context.l10n.appearanceSkinGameName,
        context.l10n.appearanceSkinGameDesc,
      ),
    ];
    return ResponsiveGrid(
      minimumWidth: 200,
      children: [
        for (final (id, name, desc) in skins)
          DeckPanel(
            highlight: appearance.skin == id,
            padding: 20,
            child: InkWell(
              onTap: () => controller.change(_withSkin(id)),
              child: _SkinCard(
                id: id,
                preview: _preview(context, id),
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
    required this.preview,
    required this.name,
    required this.desc,
    required this.selected,
  });
  final String id, name, desc;
  final ThemeData preview;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuraPreview(skin: id, theme: preview),
        const SizedBox(height: 16),
        DeckIcon(
          id == 'clean'
              ? Icons.contrast
              : id == 'cyber'
              ? Icons.hexagon_outlined
              : id == 'orbital'
              ? Icons.radar
              : id == 'game'
              ? Icons.shield_outlined
              : Icons.auto_stories_outlined,
          size: 36,
          color: theme.colorScheme.accentInk,
        ),
        const SizedBox(height: 16),
        Text(name, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(desc),
        if (id == 'game') ...[
          const SizedBox(height: 12),
          HudBar(value: .7, label: context.l10n.appearanceHudPreview),
        ],
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
                      font == 'System'
                          ? context.l10n.appearanceFontSystem
                          : font,
                      style: TextStyle(
                        fontFamily: deckFontFamily(font),
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aa / 0123456789',
                      style: TextStyle(fontFamily: deckFontFamily(font)),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
