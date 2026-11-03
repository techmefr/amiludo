import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/functional/Appearance/presentation/cubit/appearance_cubit.dart';
import 'package:amiludo/layers/functional/Appearance/presentation/appearance_style_grids.dart';
import 'package:amiludo/layers/technical/Theme/text_prompt.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  Future<void> _importTheme(
    BuildContext context,
    AppearanceCubit controller,
  ) async {
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
      await controller.change(imported);
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

  @override
  Widget build(BuildContext context) {
    final ws = context.watch<AppearanceCubit>().state,
        a = ws.appearance,
        controller = context.read<AppearanceCubit>(),
        theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AppearanceHeading(controller: controller),
        SectionHeading(tr(context, '01 / Votre univers', '01 / Your world')),
        AppearanceSkinGrid(appearance: a, controller: controller),
        _ChoiceSection(
          title: tr(context, '02 / Lumière', '02 / Light'),
          options: [
            ('light', tr(context, 'Clair', 'Light')),
            ('dark', tr(context, 'Sombre', 'Dark')),
            ('system', tr(context, 'Système', 'System')),
          ],
          selected: a.mode,
          change: (v) => controller.change(a.copyWith(mode: v)),
        ),
        SectionHeading(tr(context, '03 / Palette', '03 / Palette')),
        AppearancePaletteGrid(appearance: a, controller: controller),
        SectionHeading(tr(context, '04 / Caractères', '04 / Typeface')),
        AppearanceFontGrid(appearance: a, controller: controller),
        _ChoiceSection(
          title: tr(context, '05 / Formes', '05 / Shapes'),
          options: [
            ('cut', tr(context, 'Biseautées', 'Beveled')),
            ('square', tr(context, 'Nettes', 'Sharp')),
            ('soft', tr(context, 'Douces', 'Soft')),
            ('round', tr(context, 'Arrondies', 'Rounded')),
          ],
          selected: a.shape,
          change: (v) => controller.change(a.copyWith(shape: v)),
        ),
        SectionHeading(tr(context, '06 / Confort', '06 / Comfort')),
        _ComfortPanel(appearance: a, controller: controller),
        _ChoiceSection(
          title: 'Langue / Language',
          options: const [('fr', 'Français'), ('en', 'English')],
          selected: a.language,
          change: (v) => controller.change(a.copyWith(language: v)),
        ),
        SectionHeading(tr(context, '07 / Vos profils', '07 / Your profiles')),
        _ProfileActions(
          appearance: a,
          controller: controller,
          onImport: () => _importTheme(context, controller),
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < ws.profiles.length; i++)
          _ProfileTile(
            profile: ws.profiles[i],
            onApply: () => controller.change(ws.profiles[i].appearance),
            onRemove: () => controller.removeProfile(i),
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

class _AppearanceHeading extends StatelessWidget {
  const _AppearanceHeading({required this.controller});
  final AppearanceCubit controller;
  @override
  Widget build(BuildContext context) {
    return DeckHeading(
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
        onPressed: () => controller.change(const Appearance()),
        child: Text(tr(context, 'Réinitialiser', 'Reset')),
      ),
    );
  }
}

class _ChoiceSection extends StatelessWidget {
  const _ChoiceSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.change,
  });
  final String title;
  final List<(String, String)> options;
  final String selected;
  final void Function(String) change;
  @override
  Widget build(BuildContext context) {
    return Column(
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
  }
}

class _ComfortPanel extends StatelessWidget {
  const _ComfortPanel({required this.appearance, required this.controller});
  final Appearance appearance;
  final AppearanceCubit controller;

  Widget _toggle(String title, bool value, Appearance Function(bool) update) =>
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title),
        value: value,
        onChanged: (v) => controller.change(update(v)),
      );

  @override
  Widget build(BuildContext context) {
    final a = appearance;
    return DeckPanel(
      child: Column(
        children: [
          _toggle(
            tr(context, 'Affichage compact', 'Compact layout'),
            a.compact,
            (v) => a.copyWith(compact: v),
          ),
          _toggle(
            tr(context, 'Lecture agrandie', 'Larger text'),
            a.large,
            (v) => a.copyWith(large: v),
          ),
          _toggle(
            tr(context, 'Animations', 'Animations'),
            a.motion,
            (v) => a.copyWith(motion: v),
          ),
          _toggle(
            tr(context, 'Sons des alertes', 'Alert sounds'),
            a.sound,
            (v) => a.copyWith(sound: v),
          ),
          _toggle(
            tr(context, 'Vibrations', 'Haptic feedback'),
            a.haptics,
            (v) => a.copyWith(haptics: v),
          ),
          _toggle(
            tr(
              context,
              'Garder l’écran allumé pendant une partie',
              'Keep screen awake during games',
            ),
            a.keepAwake,
            (v) => a.copyWith(keepAwake: v),
          ),
        ],
      ),
    );
  }
}

class _ProfileActions extends StatelessWidget {
  const _ProfileActions({
    required this.appearance,
    required this.controller,
    required this.onImport,
  });
  final Appearance appearance;
  final AppearanceCubit controller;
  final VoidCallback onImport;
  @override
  Widget build(BuildContext context) {
    return Wrap(
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
          label: Text(tr(context, 'Enregistrer ce style', 'Save this style')),
        ),
        OutlinedButton(
          onPressed: () => FileTransfer.shareText(
            jsonEncode({
              'format': 'table-companion-style',
              'version': 3,
              'settings': appearance.toJson(),
            }),
            'mon-style.json',
          ),
          child: Text(tr(context, 'Exporter', 'Export')),
        ),
        OutlinedButton(
          onPressed: onImport,
          child: Text(tr(context, 'Importer', 'Import')),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.profile,
    required this.onApply,
    required this.onRemove,
  });
  final StyleProfile profile;
  final VoidCallback onApply, onRemove;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DeckPanel(
        padding: 12,
        child: ListTile(
          title: Text(profile.name),
          subtitle: Text(
            '${profile.appearance.skin} / ${profile.appearance.palette}',
          ),
          onTap: onApply,
          trailing: IconButton(
            tooltip: tr(context, 'Supprimer ce profil', 'Delete profile'),
            onPressed: onRemove,
            icon: const DeckIcon(Icons.close),
          ),
        ),
      ),
    );
  }
}
