import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../technical/Appearance/appearance.dart';
import '../../../technical/Theme/deck_theme.dart';
import '../../../technical/Theme/deck_widgets.dart';
import '../../../technical/Files/file_transfer.dart';
import '../../Workspace/workspace_controller.dart';
import '../../Workspace/presentation/game_setup.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(workspaceProvider).requireValue,
        a = ws.appearance,
        controller = ref.read(workspaceProvider.notifier),
        theme = Theme.of(context);
    Widget choices(
      String title,
      List<(String, String)> options,
      String selected,
      void Function(String) change,
    ) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(title),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options
              .map(
                (o) => ChoiceChip(
                  label: Text(o.$2),
                  selected: selected == o.$1,
                  onSelected: (_) => change(o.$1),
                ),
              )
              .toList(),
        ),
      ],
    );
    Future<void> importTheme() async {
      try {
        final text = await FileTransfer.openJson();
        if (text == null) return;
        final json = Map<String, dynamic>.from(jsonDecode(text) as Map);
        if (![1, 2, 3].contains(json['version'])) {
          throw const FormatException('Version incompatible');
        }
        final imported = Appearance.fromJson(
          Map<String, dynamic>.from(json['settings'] as Map),
        );
        await controller.appearance(imported);
        if (context.mounted) {
          notify(context, tr(context, 'Thème importé', 'Theme imported'));
        }
      } catch (error) {
        if (context.mounted) {
          notify(
            context,
            '${tr(context, 'Import impossible', 'Import failed')} : $error',
          );
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeckHeading(
          eyebrow: tr(
            context,
            'Votre univers / vos règles',
            'Your world / your rules',
          ),
          title: tr(context, 'À votre image', 'Make it yours'),
          subtitle: tr(
            context,
            'Quatre univers, onze palettes, sept polices. Tout reste sur cet appareil.',
            'Four worlds, eleven palettes, seven fonts. Saved on this device.',
          ),
          action: OutlinedButton(
            onPressed: () => controller.appearance(const Appearance()),
            child: Text(tr(context, 'Réinitialiser', 'Reset')),
          ),
        ),
        SectionHeading(tr(context, '01 / Votre univers', '01 / Your world')),
        ResponsiveGrid(
          minimumWidth: 200,
          children: [
            for (final (id, name, desc) in [
              (
                'play',
                'Playroom',
                'Des couleurs, des cartes et l’envie de jouer.',
              ),
              ('cyber', 'CYBERDECK', 'Noir, néon, angles biseautés.'),
              ('orbital', 'ORBITAL 77', 'Ivoire, ambre, instruments rétro.'),
              ('paper', 'CARNET', 'Doux, coloré, esprit papier.'),
            ])
              DeckPanel(
                highlight: a.skin == id,
                padding: 20,
                child: InkWell(
                  onTap: () => controller.appearance(
                    a.copyWith(
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
                          ? 'NunitoSans'
                          : id == 'orbital'
                          ? 'Rajdhani'
                          : id == 'paper'
                          ? 'DMSans'
                          : 'SpaceGrotesk',
                    ),
                  ),
                  child: Column(
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
                        a.skin == id
                            ? '✓ ${tr(context, 'Sélectionné', 'Selected')}'
                            : tr(
                                context,
                                'Choisir cet univers ↗',
                                'Choose this world ↗',
                              ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        choices(
          tr(context, '02 / Lumière', '02 / Light'),
          [
            ('light', tr(context, 'Clair', 'Light')),
            ('dark', tr(context, 'Sombre', 'Dark')),
            ('system', tr(context, 'Système', 'System')),
          ],
          a.mode,
          (v) => controller.appearance(a.copyWith(mode: v)),
        ),
        SectionHeading(tr(context, '03 / Palette', '03 / Palette')),
        ResponsiveGrid(
          minimumWidth: 180,
          children: DeckPalette.values.entries.map((entry) {
            final p = entry.value;
            return DeckPanel(
              highlight: a.palette == entry.key,
              padding: 16,
              child: InkWell(
                onTap: () =>
                    controller.appearance(a.copyWith(palette: entry.key)),
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
        ),
        SectionHeading(tr(context, '04 / Caractères', '04 / Typeface')),
        ResponsiveGrid(
          minimumWidth: 220,
          children: Appearance.fonts
              .map(
                (font) => DeckPanel(
                  highlight: a.font == font,
                  padding: 20,
                  child: InkWell(
                    onTap: () => controller.appearance(a.copyWith(font: font)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          font,
                          style: TextStyle(fontFamily: font, fontSize: 22),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aa / 0123456789',
                          style: TextStyle(fontFamily: font),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        choices(
          tr(context, '05 / Formes', '05 / Shapes'),
          [
            ('cut', tr(context, 'Biseautées', 'Beveled')),
            ('square', tr(context, 'Nettes', 'Sharp')),
            ('soft', tr(context, 'Douces', 'Soft')),
            ('round', tr(context, 'Arrondies', 'Rounded')),
          ],
          a.shape,
          (v) => controller.appearance(a.copyWith(shape: v)),
        ),
        SectionHeading(tr(context, '06 / Confort', '06 / Comfort')),
        DeckPanel(
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr(context, 'Affichage compact', 'Compact layout')),
                value: a.compact,
                onChanged: (v) => controller.appearance(a.copyWith(compact: v)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr(context, 'Lecture agrandie', 'Larger text')),
                value: a.large,
                onChanged: (v) => controller.appearance(a.copyWith(large: v)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr(context, 'Animations', 'Animations')),
                value: a.motion,
                onChanged: (v) => controller.appearance(a.copyWith(motion: v)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr(context, 'Sons des alertes', 'Alert sounds')),
                value: a.sound,
                onChanged: (v) => controller.appearance(a.copyWith(sound: v)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr(context, 'Vibrations', 'Haptic feedback')),
                value: a.haptics,
                onChanged: (v) => controller.appearance(a.copyWith(haptics: v)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  tr(
                    context,
                    'Garder l’écran allumé pendant une partie',
                    'Keep screen awake during games',
                  ),
                ),
                value: a.keepAwake,
                onChanged: (v) =>
                    controller.appearance(a.copyWith(keepAwake: v)),
              ),
            ],
          ),
        ),
        choices(
          'Langue / Language',
          [('fr', 'Français'), ('en', 'English')],
          a.language,
          (v) => controller.appearance(a.copyWith(language: v)),
        ),
        SectionHeading(tr(context, '07 / Vos profils', '07 / Your profiles')),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () async {
                final name = await textPrompt(
                  context,
                  tr(context, 'Nom du profil', 'Profile name'),
                );
                if (name != null && name.trim().isNotEmpty) {
                  await controller.saveProfile(name.trim());
                }
              },
              icon: const DeckIcon(Icons.add),
              label: Text(
                tr(context, 'Enregistrer ce style', 'Save this style'),
              ),
            ),
            OutlinedButton(
              onPressed: () => FileTransfer.shareText(
                jsonEncode({
                  'format': 'table-companion-style',
                  'version': 3,
                  'settings': a.toJson(),
                }),
                'mon-style.json',
              ),
              child: Text(tr(context, 'Exporter', 'Export')),
            ),
            OutlinedButton(
              onPressed: importTheme,
              child: Text(tr(context, 'Importer', 'Import')),
            ),
          ],
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < ws.profiles.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DeckPanel(
              padding: 12,
              child: ListTile(
                title: Text(ws.profiles[i].name),
                subtitle: Text(
                  '${ws.profiles[i].appearance.skin} / ${ws.profiles[i].appearance.palette}',
                ),
                onTap: () => controller.appearance(ws.profiles[i].appearance),
                trailing: IconButton(
                  tooltip: tr(context, 'Supprimer ce profil', 'Delete profile'),
                  onPressed: () => controller.removeProfile(i),
                  icon: const DeckIcon(Icons.close),
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
        Text(
          tr(
            context,
            'Polices intégrées à l’application. Les profils sont personnels à cet appareil ; vous pouvez les partager par fichier.',
            'Fonts are bundled. Profiles belong to this device and can be shared as files.',
          ),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
