import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../technical/Theme/deck_widgets.dart';
import '../../Templates/domain/game_template.dart';
import '../workspace_controller.dart';

Future<String?> textPrompt(
  BuildContext context,
  String title, {
  String initial = '',
  String? label,
  bool multiline = false,
}) async {
  final controller = TextEditingController(text: initial);
  try {
    return await showFormDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: controller,
            autofocus: true,
            minLines: multiline ? 4 : 1,
            maxLines: multiline ? 8 : 1,
            maxLength: multiline ? 4000 : 100,
            decoration: InputDecoration(labelText: label),
            onSubmitted: multiline ? null : (v) => Navigator.pop(dialog, v),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: Text(tr(context, 'Annuler', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, controller.text),
            child: Text(tr(context, 'Enregistrer', 'Save')),
          ),
        ],
      ),
    );
  } finally {
    controller.dispose();
  }
}

Future<void> showNewGame(
  BuildContext context,
  WidgetRef ref, {
  GameTemplate? template,
  List<String>? names,
}) async {
  final ws = ref.read(workspaceProvider).requireValue;
  final title = TextEditingController(text: template?.name ?? ''),
      people = TextEditingController(
        text: (names ?? ws.playerNames).join('\n'),
      );
  var chosen = template ?? GameTemplate.builtIn.first;
  final form = GlobalKey<FormState>();
  try {
    final accepted = await showFormDialog<bool>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (dialog, setState) => AlertDialog(
          title: Text(tr(context, 'Préparer la table', 'Set up the table')),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Form(
                key: form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: title,
                      maxLength: 80,
                      decoration: InputDecoration(
                        labelText: tr(context, 'Nom de la partie', 'Game name'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: chosen.id,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: tr(context, 'Modèle', 'Template'),
                      ),
                      items: [...GameTemplate.builtIn, ...ws.templates]
                          .map(
                            (t) => DropdownMenuItem(
                              value: t.id,
                              child: Text(
                                t.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (id) => setState(
                        () => chosen = [
                          ...GameTemplate.builtIn,
                          ...ws.templates,
                        ].firstWhere((t) => t.id == id),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: people,
                      minLines: 4,
                      maxLines: 8,
                      decoration: InputDecoration(
                        labelText: tr(
                          context,
                          'Joueurs ou équipes : un nom par ligne',
                          'Players or teams: one name per line',
                        ),
                        helperText: tr(
                          context,
                          '1 à 32 participants, sans doublon.',
                          '1–32 unique participants.',
                        ),
                      ),
                      validator: (text) {
                        final values = text!
                            .split('\n')
                            .map((n) => n.trim())
                            .where((n) => n.isNotEmpty)
                            .toList();
                        return values.isEmpty ||
                                values.length > 32 ||
                                values.toSet().length != values.length ||
                                values.any((n) => n.length > 40)
                            ? tr(
                                context,
                                'Vérifiez les noms (40 caractères maximum).',
                                'Check names (40 characters maximum).',
                              )
                            : null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: Text(tr(context, 'Annuler', 'Cancel')),
            ),
            FilledButton(
              onPressed: () {
                if (form.currentState!.validate()) Navigator.pop(dialog, true);
              },
              child: Text(tr(context, 'À vous de jouer', 'Start playing')),
            ),
          ],
        ),
      ),
    );
    if (accepted == true) {
      await ref
          .read(workspaceProvider.notifier)
          .startGame(
            title.text,
            people.text
                .split('\n')
                .map((n) => n.trim())
                .where((n) => n.isNotEmpty)
                .toList(),
            chosen,
          );
      if (context.mounted) context.go('/game');
    }
  } finally {
    title.dispose();
    people.dispose();
  }
}
