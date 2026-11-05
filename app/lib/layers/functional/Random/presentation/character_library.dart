import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/random_cubit.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class CharacterLibrary extends StatelessWidget {
  const CharacterLibrary({super.key});
  Future<void> import(BuildContext context) async {
    final ctl = context.read<RandomCubit>();
    try {
      final text = await FileTransfer.openJson();
      if (text == null) return;
      final j = jsonDecode(text) as Map<String, dynamic>;
      if (j['format'] != 'table-companion-character' || j['version'] != 1) {
        if (context.mounted) {
          notify(context, context.l10n.randomImportFailedIncompatibleSheet);
        }
        return;
      }
      final c = GameCharacter.fromJson(
        Map<String, dynamic>.from(j['character'] as Map),
      );
      if (ctl.state.characters.any((v) => v.id == c.id)) {
        if (!context.mounted ||
            !await confirm(
              context,
              context.l10n.randomReplaceThisSheet,
              c.name,
            )) {
          return;
        }
      }
      await ctl.saveCharacter(c);
      if (context.mounted) {
        notify(context, context.l10n.randomSheetImported);
      }
    } catch (e) {
      if (context.mounted) {
        notify(context, context.l10n.randomImportFailed(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = context.watch<RandomCubit>().state.characters;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(context.l10n.randomMyCharacters),
        OutlinedButton.icon(
          onPressed: () => import(context),
          icon: const DeckIcon(Icons.file_open_outlined),
          label: Text(context.l10n.randomImportAJsonSheet),
        ),
        const SizedBox(height: 16),
        if (records.isEmpty)
          Text(context.l10n.randomYourSavedCharactersWillAppear),
        for (final c in records) _CharacterCard(character: c),
      ],
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({required this.character});

  final GameCharacter character;

  Future<void> _remove(BuildContext context) async {
    final controller = context.read<RandomCubit>();
    if (await confirm(
      context,
      context.l10n.randomDeleteThisCharacter,
      character.name,
    )) {
      await controller.removeCharacter(character.id);
    }
  }

  void _export() => FileTransfer.shareText(
    jsonEncode({
      'format': 'table-companion-character',
      'version': 1,
      'character': character.toJson(),
    }),
    'personnage-${character.id}.json',
  );

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: DeckPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(character.name, style: Theme.of(context).textTheme.titleLarge),
          Text(character.packName),
          for (final e in character.choices.entries)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '${e.key} : ${e.value.map((v) => v.name).join(" + ")}\n${e.value.map((v) => v.description).where((s) => s.isNotEmpty).join("\n")}',
              ),
            ),
          Wrap(
            spacing: 12,
            children: [
              TextButton(
                onPressed: _export,
                child: Text(context.l10n.randomExportTheSheet),
              ),
              TextButton(
                onPressed: () => _remove(context),
                child: Text(context.l10n.randomDelete),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
