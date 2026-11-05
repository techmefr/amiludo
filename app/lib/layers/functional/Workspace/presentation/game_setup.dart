import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/cubit/workspace_cubit.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
        ? context.l10n.workspaceCheckTheNames40Characters
        : null;
  }

  Future<void> _start() async {
    if (!form.currentState!.validate()) return;
    try {
      await context.read<WorkspaceCubit>().startGame(
        title.text,
        people.text
            .split('\n')
            .map((n) => n.trim())
            .where((n) => n.isNotEmpty)
            .toList(),
        chosen,
      );
    } on GameError {
      if (mounted) {
        notify(context, context.l10n.workspacePick1To32Different);
      }
      return;
    }
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
      title: context.l10n.workspaceSetUpTheTable,
      fallback: '/',
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DeckHeading(
              eyebrow: context.l10n.workspaceNewGame,
              title: context.l10n.workspaceWhoIsPlaying,
              subtitle: context.l10n.workspaceANameAPackYour,
            ),
            TextFormField(
              controller: title,
              maxLength: 80,
              decoration: InputDecoration(
                labelText: context.l10n.workspaceGameName,
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
              child: Text(context.l10n.workspaceStartPlaying),
            ),
          ],
        ),
      ),
    );
  }
}
