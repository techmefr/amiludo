import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/random_cubit.dart';

class CharacterLibrary extends StatelessWidget {
  const CharacterLibrary({super.key});
  Future<void> import(BuildContext context) async {
    final ctl = context.read<RandomCubit>();
    try {
      final text = await FileTransfer.openJson();
      if (text == null) return;
      final j = jsonDecode(text) as Map<String, dynamic>;
      if (j['format'] != 'table-companion-character' || j['version'] != 1) {
        throw const FormatException('Fiche incompatible');
      }
      final c = GameCharacter.fromJson(
        Map<String, dynamic>.from(j['character'] as Map),
      );
      if (ctl.state.characters.any((v) => v.id == c.id)) {
        if (!context.mounted ||
            !await confirm(context, 'Remplacer cette fiche ?', c.name)) {
          return;
        }
      }
      await ctl.saveCharacter(c);
      if (context.mounted) notify(context, 'Fiche importée');
    } catch (e) {
      if (context.mounted) notify(context, 'Import impossible : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = context.watch<RandomCubit>().state.characters;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading('Mes personnages'),
        OutlinedButton.icon(
          onPressed: () => import(context),
          icon: const DeckIcon(Icons.file_open_outlined),
          label: const Text('Importer une fiche JSON'),
        ),
        const SizedBox(height: 16),
        if (records.isEmpty)
          const Text(
            'Vos personnages enregistrés apparaîtront ici, même si leur pack est supprimé.',
          ),
        for (final c in records)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DeckPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name, style: Theme.of(context).textTheme.titleLarge),
                  Text(c.packName),
                  for (final e in c.choices.entries)
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
                        onPressed: () => FileTransfer.shareText(
                          jsonEncode({
                            'format': 'table-companion-character',
                            'version': 1,
                            'character': c.toJson(),
                          }),
                          'personnage-${c.id}.json',
                        ),
                        child: const Text('Exporter la fiche'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final controller = context.read<RandomCubit>();
                          if (await confirm(
                            context,
                            'Supprimer ce personnage ?',
                            c.name,
                          )) {
                            await controller.removeCharacter(c.id);
                          }
                        },
                        child: const Text('Supprimer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
