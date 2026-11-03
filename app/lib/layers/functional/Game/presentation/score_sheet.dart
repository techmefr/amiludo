import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/functional/Game/presentation/cubit/game_cubit.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/pack_components.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';

enum _SheetError { missingQuantity, invalidNumber }

class ScoreSheet extends StatefulWidget {
  const ScoreSheet({super.key, required this.playerId});
  final String playerId;
  @override
  State<ScoreSheet> createState() => _ScoreSheetState();
}

class _ScoreSheetState extends State<ScoreSheet> {
  final input = <String, TextEditingController>{};
  _SheetError? error;
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
      return FullPage(
        title: tr(context, 'Décompte', 'Scoring'),
        fallback: '/game',
        child: Text(
          tr(
            context,
            'Créez une partie pour utiliser cette feuille.',
            'Create a game to use this sheet.',
          ),
        ),
      );
    }
    final rules = g.pack?.scoring ?? <ScoreRule>[];
    final ready = rules.isNotEmpty && g.finishedAt == null;
    final totals = <String, double>{};
    for (final r in rules) {
      final c = input.putIfAbsent(r.name, () => TextEditingController());
      final quantity = double.tryParse(c.text.trim().replaceAll(',', '.'));
      final total = quantity == null ? null : _total(r, quantity);
      if (total != null) totals[r.name] = total;
    }
    return FullPage(
      title: '${tr(context, 'Décompte', 'Scoring')} · ${p.name}',
      fallback: '/game',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetIntro(round: g.round, free: rules.isEmpty),
          for (final r in rules) _ruleField(g, p, r, totals),
          if (error != null)
            Text(
              _errorText(error!),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (ready)
            FilledButton(
              onPressed: () => _apply(g, p, rules),
              child: Text(
                tr(context, 'Appliquer ce décompte', 'Apply this scoring'),
              ),
            ),
        ],
      ),
    );
  }

  double? _total(ScoreRule rule, double quantity) {
    try {
      return rule.calculate(quantity);
    } on FormatException {
      return null;
    }
  }

  String _errorText(_SheetError e) => switch (e) {
    _SheetError.missingQuantity => tr(
      context,
      'Renseignez au moins une quantité.',
      'Enter at least one quantity.',
    ),
    _SheetError.invalidNumber => tr(
      context,
      'Saisissez des nombres valides.',
      'Enter valid numbers.',
    ),
  };

  Widget _ruleField(
    GameSession g,
    Player p,
    ScoreRule r,
    Map<String, double> totals,
  ) => Padding(
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
            '${tr(context, 'Total actuel', 'Current total')} : ${numberText(g.score(p.id, inRound: g.round, category: r.name))} · ${tr(context, 'Calcul', 'Result')} : ${totals.containsKey(r.name) ? numberText(totals[r.name]!) : "—"}',
      ),
      onChanged: (_) => setState(() {}),
    ),
  );

  Future<void> _apply(GameSession g, Player p, List<ScoreRule> rules) async {
    final quantities = <String, double>{};
    for (final r in rules) {
      final text = input[r.name]!.text.trim();
      if (text.isEmpty) continue;
      final quantity = double.tryParse(text.replaceAll(',', '.'));
      if (quantity == null) {
        setState(() => error = _SheetError.invalidNumber);
        return;
      }
      quantities[r.name] = quantity;
    }
    if (quantities.isEmpty) {
      setState(() => error = _SheetError.missingQuantity);
      return;
    }
    var updated = g;
    for (final r in rules) {
      if (quantities.containsKey(r.name)) {
        final total = _total(r, quantities[r.name]!);
        if (total == null) {
          setState(() => error = _SheetError.invalidNumber);
          return;
        }
        updated = updated.addScore(
          p.id,
          total - updated.score(p.id, inRound: g.round, category: r.name),
          r.name,
        );
      }
    }
    await context.read<GameCubit>().saveGame(updated);
    if (mounted) context.pop();
  }
}

class _SheetIntro extends StatelessWidget {
  const _SheetIntro({required this.round, required this.free});
  final int round;
  final bool free;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '${tr(context, 'Manche', 'Round')} $round',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 12),
      Text(
        tr(
          context,
          'Saisissez les quantités finales. Les catégories renseignées remplacent leur total pour cette manche. Les champs laissés vides restent inchangés.',
          'Enter the final quantities. Filled categories replace their total for this round. Empty fields stay unchanged.',
        ),
      ),
      const SizedBox(height: 24),
      if (free)
        Text(
          tr(
            context,
            'Ce modèle utilise les scores libres. Ajoutez des règles de calcul dans le builder puis démarrez une partie avec ce pack.',
            'This template uses free scores. Add scoring rules in the builder, then start a game with this pack.',
          ),
        ),
    ],
  );
}
