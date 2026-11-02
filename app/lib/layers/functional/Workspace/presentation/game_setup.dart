import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../technical/Theme/deck_widgets.dart';
import '../../../technical/Theme/full_page.dart';
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

  final route = MaterialPageRoute<String>(
    builder: (page) => FullPage(
      title: title,
      fallback: '/game',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            minLines: multiline ? 4 : 1,
            maxLines: multiline ? 8 : 1,
            maxLength: multiline ? 4000 : 100,
            decoration: InputDecoration(labelText: label),
            onSubmitted: multiline ? null : (v) => Navigator.pop(page, v),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.pop(page, controller.text),
            child: Text(tr(context, 'Enregistrer', 'Save')),
          ),
        ],
      ),
    ),
  );
  try {
    final value = await Navigator.of(context).push(route);
    await route.completed;
    return value;
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
  await Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => GameSetupPage(template: template, names: names),
    ),
  );
}

class GameSetupPage extends ConsumerStatefulWidget {
  const GameSetupPage({super.key, this.template, this.names});
  final GameTemplate? template;
  final List<String>? names;
  @override
  ConsumerState<GameSetupPage> createState() => _GameSetupPageState();
}

class _GameSetupPageState extends ConsumerState<GameSetupPage> {
  late final TextEditingController title, people;
  late GameTemplate chosen;
  final form = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    final ws = ref.read(workspaceProvider).requireValue;
    chosen = widget.template ?? GameTemplate.builtIn.first;
    title = TextEditingController(text: widget.template?.name ?? '');
    people = TextEditingController(
      text: (widget.names ?? ws.playerNames).join('\n'),
    );
  }

  @override
  void dispose() {
    title.dispose();
    people.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ws = ref.watch(workspaceProvider).requireValue;
    final templates = <String, GameTemplate>{
      for (final t in [...GameTemplate.builtIn, ...ws.templates, chosen])
        t.id: t,
    };
    return FullPage(
      title: tr(context, 'Préparer la table', 'Set up the table'),
      fallback: '/',
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              decoration: const InputDecoration(labelText: 'Pack / modèle'),
              items: templates.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t.id,
                      child: Text(t.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => chosen = templates[v]!),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: people,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Joueurs ou équipes : un nom par ligne',
                helperText: '1 à 32 participants, sans doublon.',
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
                    ? 'Vérifiez les noms (40 caractères maximum).'
                    : null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                if (!form.currentState!.validate()) return;
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
                if (context.mounted) {
                  Navigator.of(context).pop();
                  context.go('/game');
                }
              },
              child: Text(tr(context, 'À vous de jouer', 'Start playing')),
            ),
          ],
        ),
      ),
    );
  }
}
