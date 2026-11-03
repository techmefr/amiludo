import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/cubit/workspace_cubit.dart';

class GameSetupPage extends StatefulWidget {
  const GameSetupPage({super.key, this.template, this.names});
  final GameTemplate? template;
  final List<String>? names;
  @override
  State<GameSetupPage> createState() => _GameSetupPageState();
}

class _GameSetupPageState extends State<GameSetupPage> {
  late final TextEditingController title, people;
  late GameTemplate chosen;
  final form = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    final ws = context.read<WorkspaceCubit>().state.workspace;
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

  String? _validatePlayers(String? text) {
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
  }

  Future<void> _start() async {
    if (!form.currentState!.validate()) return;
    await context.read<WorkspaceCubit>().startGame(
      title.text,
      people.text
          .split('\n')
          .map((n) => n.trim())
          .where((n) => n.isNotEmpty)
          .toList(),
      chosen,
    );
    if (mounted) {
      Navigator.of(context).pop();
      context.go('/game');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ws = context.watch<WorkspaceCubit>().state.workspace;
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
            DeckHeading(
              eyebrow: tr(context, 'Nouvelle partie', 'New game'),
              title: tr(context, 'Qui est à la table ?', 'Who is playing?'),
              subtitle: tr(
                context,
                'Un nom, un pack, vos joueurs. Le reste se règle en jouant.',
                'A name, a pack, your players. The rest happens as you play.',
              ),
            ),
            TextFormField(
              controller: title,
              maxLength: 80,
              decoration: InputDecoration(
                labelText: tr(context, 'Nom de la partie', 'Game name'),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              style: Theme.of(context).textTheme.bodyLarge,
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
              validator: _validatePlayers,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _start,
              child: Text(tr(context, 'À vous de jouer', 'Start playing')),
            ),
          ],
        ),
      ),
    );
  }
}
