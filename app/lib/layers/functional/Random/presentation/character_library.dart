import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../technical/Theme/deck_widgets.dart';
import '../../../technical/Files/file_transfer.dart';
import '../../Templates/domain/character_pack.dart';
import '../../Workspace/workspace_controller.dart';

class CharacterLibrary extends ConsumerWidget {
  const CharacterLibrary({super.key});
  Future<void> import(BuildContext context, WidgetRef ref) async {
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
      final ctl = ref.read(workspaceProvider.notifier);
      if (ctl.data.characters.any((v) => v.id == c.id)) {
        if (!context.mounted ||
            !await confirm(context, 'Remplacer cette fiche ?', c.name)) {
          return;
        }
      }
      await ctl.saveWorkspace(
        ctl.data.copyWith(
          characters: [c, ...ctl.data.characters.where((v) => v.id != c.id)],
        ),
      );
      if (context.mounted) notify(context, 'Fiche importée');
    } catch (e) {
      if (context.mounted) notify(context, 'Import impossible : $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(workspaceProvider).requireValue.characters;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading('Mes personnages'),
        OutlinedButton.icon(
          onPressed: () => import(context, ref),
          icon: const Icon(Icons.file_open_outlined),
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
                          if (await confirm(
                            context,
                            'Supprimer ce personnage ?',
                            c.name,
                          )) {
                            final controller = ref.read(
                              workspaceProvider.notifier,
                            );
                            await controller.saveWorkspace(
                              controller.data.copyWith(
                                characters: controller.data.characters
                                    .where((v) => v.id != c.id)
                                    .toList(),
                              ),
                            );
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
