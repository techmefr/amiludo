import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/functional/Game/presentation/cubit/game_cubit.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/pack_components.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';

class ScoreSheet extends StatefulWidget {
  const ScoreSheet({super.key, required this.playerId});
  final String playerId;
  @override
  State<ScoreSheet> createState() => _ScoreSheetState();
}

class _ScoreSheetState extends State<ScoreSheet> {
  final input = <String, TextEditingController>{};
  String? error;
  @override
  void dispose() {
    for (final c in input.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = context.watch<GameCubit>().state.current,
        p = g?.players.where((p) => p.id == widget.playerId).firstOrNull;
    if (g == null || p == null) {
      return const FullPage(
        title: 'Décompte',
        fallback: '/game',
        child: Text('Créez une partie pour utiliser cette feuille.'),
      );
    }
    final rules = g.pack?.scoring ?? <ScoreRule>[];
    final ready = rules.isNotEmpty && g.finishedAt == null;
    final totals = <String, double>{};
    for (final r in rules) {
      final c = input.putIfAbsent(r.name, () => TextEditingController());
      try {
        if (c.text.trim().isNotEmpty) {
          totals[r.name] = r.calculate(
            double.parse(c.text.replaceAll(',', '.')),
          );
        }
      } on FormatException {
        totals.remove(r.name);
      }
    }
    return FullPage(
      title: 'Décompte · ${p.name}',
      fallback: '/game',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manche ${g.round}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'Saisissez les quantités finales. Les catégories renseignées remplacent leur total pour cette manche. Les champs laissés vides restent inchangés.',
          ),
          const SizedBox(height: 24),
          if (rules.isEmpty)
            const Text(
              'Ce modèle utilise les scores libres. Ajoutez des règles de calcul dans le builder puis démarrez une partie avec ce pack.',
            ),
          for (final r in rules)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: TextField(
                controller: input[r.name],
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  labelText: r.name,
                  helperText:
                      'Total actuel : ${numberText(g.score(p.id, inRound: g.round, category: r.name))} · Calcul : ${totals.containsKey(r.name) ? numberText(totals[r.name]!) : "—"}',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          if (error != null)
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (ready)
            FilledButton(
              onPressed: () async {
                try {
                  final quantities = <String, double>{};
                  for (final r in rules) {
                    final text = input[r.name]!.text.trim();
                    if (text.isNotEmpty) {
                      quantities[r.name] = double.parse(
                        text.replaceAll(',', '.'),
                      );
                    }
                  }
                  if (quantities.isEmpty) {
                    throw const FormatException(
                      'Renseignez au moins une quantité.',
                    );
                  }
                  var updated = g;
                  for (final r in rules) {
                    if (quantities.containsKey(r.name)) {
                      final total = r.calculate(quantities[r.name]!);
                      updated = updated.addScore(
                        p.id,
                        total -
                            updated.score(
                              p.id,
                              inRound: g.round,
                              category: r.name,
                            ),
                        r.name,
                      );
                    }
                  }
                  await context.read<GameCubit>().saveGame(updated);
                  if (context.mounted) context.pop();
                } on FormatException catch (e) {
                  setState(() => error = e.message);
                }
              },
              child: const Text('Appliquer ce décompte'),
            ),
        ],
      ),
    );
  }
}
