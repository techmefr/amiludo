import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tokens/type_roles.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/functional/Game/presentation/cubit/game_cubit.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/pack_components.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
        title: context.l10n.templatesScoring,
        fallback: '/game',
        child: Text(context.l10n.gameCreateAGameToUse),
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
      title: '${context.l10n.templatesScoring} · ${p.name}',
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
              child: Text(context.l10n.gameApplyThisScoring),
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
    _SheetError.missingQuantity => context.l10n.gameEnterAtLeastOneQuantity,
    _SheetError.invalidNumber => context.l10n.gameEnterValidNumbers,
  };

  Widget _ruleField(
    GameSession g,
    Player p,
    ScoreRule r,
    Map<String, double> totals,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: Space.lg),
    child: TextField(
      controller: input[r.name],
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: InputDecoration(
        labelText: r.name,
        helperText:
            '${context.l10n.gameCurrentTotal} : ${numberText(g.score(p.id, inRound: g.round, category: r.name))} · ${context.l10n.gameResult} : ${totals.containsKey(r.name) ? numberText(totals[r.name]!) : "—"}',
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
        '${context.l10n.gameRound} $round',
        style: TypeRoles.sectionTitle(context),
      ),
      const SizedBox(height: Space.md),
      Text(context.l10n.gameEnterTheFinalQuantitiesFilled),
      const SizedBox(height: Space.xl),
      if (free) Text(context.l10n.gameThisTemplateUsesFreeScores),
    ],
  );
}
