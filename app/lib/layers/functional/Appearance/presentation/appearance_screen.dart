import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/technical/Locale/supported_languages.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_segmented.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/functional/Appearance/presentation/cubit/appearance_cubit.dart';
import 'package:amiludo/layers/functional/Appearance/presentation/appearance_style_grids.dart';
import 'package:amiludo/layers/functional/Appearance/presentation/sensor_sensitivity_section.dart';
import 'package:amiludo/layers/technical/Theme/text_prompt.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
        notify(context, context.l10n.appearanceThemeImported);
      }
    } catch (error) {
      if (context.mounted) {
        notify(context, '${context.l10n.appearanceImportFailed} : $error');
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
        SectionHeading(context.l10n.appearance01YourWorld),
        AppearanceSkinGrid(appearance: a, controller: controller),
        SectionHeading(context.l10n.appearance02Light),
        DeckSegmented<String>(
          options: [
            ('light', context.l10n.appearanceLight),
            ('dark', context.l10n.appearanceDark),
            ('system', context.l10n.appearanceSystem),
          ],
          selected: a.mode,
          onChanged: (v) => controller.change(a.copyWith(mode: v)),
        ),
        SectionHeading(context.l10n.appearance03Palette),
        AppearancePaletteGrid(appearance: a, controller: controller),
        SectionHeading(context.l10n.appearance04Typeface),
        AppearanceFontGrid(appearance: a, controller: controller),
        _ChoiceSection(
          title: context.l10n.appearance05Shapes,
          options: [
            ('cut', context.l10n.appearanceBeveled),
            ('square', context.l10n.appearanceSharp),
            ('soft', context.l10n.appearanceSoft),
            ('round', context.l10n.appearanceRounded),
          ],
          selected: a.shape,
          change: (v) => controller.change(a.copyWith(shape: v)),
        ),
        SectionHeading(context.l10n.appearance06Comfort),
        _ComfortPanel(appearance: a, controller: controller),
        _ChoiceSection(
          title: context.l10n.appearanceLanguageTitle,
          options: [
            (autoLanguage, context.l10n.appearanceLanguageAuto),
            for (final language in supportedLanguages)
              (language.code, '${language.flag} ${language.name}'),
          ],
          selected: a.language,
          change: (v) => controller.change(a.copyWith(language: v)),
        ),
        SensorSensitivitySection(appearance: a, change: controller.change),
        SectionHeading(context.l10n.appearance07YourProfiles),
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
          context.l10n.appearanceFontsAreBundledProfilesBelong,
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
      eyebrow: context.l10n.appearanceYourWorldYourRules,
      title: context.l10n.appearanceMakeItYours,
      subtitle: context.l10n.appearanceFourWorldsElevenPalettesSeven,
      action: OutlinedButton(
        onPressed: () => controller.change(const Appearance()),
        child: Text(context.l10n.appearanceReset),
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
            context.l10n.appearanceCompactLayout,
            a.compact,
            (v) => a.copyWith(compact: v),
          ),
          _toggle(
            context.l10n.appearanceLargerText,
            a.large,
            (v) => a.copyWith(large: v),
          ),
          _toggle(
            context.l10n.appearanceAnimations,
            a.motion,
            (v) => a.copyWith(motion: v),
          ),
          _toggle(
            context.l10n.appearanceDice3d,
            a.dice3d,
            (v) => a.copyWith(dice3d: v),
          ),
          _toggle(
            context.l10n.appearanceAlertSounds,
            a.sound,
            (v) => a.copyWith(sound: v),
          ),
          _toggle(
            context.l10n.appearanceHapticFeedback,
            a.haptics,
            (v) => a.copyWith(haptics: v),
          ),
          _toggle(
            context.l10n.appearanceKeepScreenAwakeDuringGames,
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
              context.l10n.appearanceProfileName,
            );
            if (name != null && name.trim().isNotEmpty) {
              await controller.saveProfile(name.trim());
            }
          },
          icon: const DeckIcon(Icons.add),
          label: Text(context.l10n.appearanceSaveThisStyle),
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
          child: Text(context.l10n.appearanceExport),
        ),
        OutlinedButton(
          onPressed: onImport,
          child: Text(context.l10n.appearanceImport),
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
            tooltip: context.l10n.appearanceDeleteProfile,
            onPressed: onRemove,
            icon: const DeckIcon(Icons.close),
          ),
        ),
      ),
    );
  }
}
