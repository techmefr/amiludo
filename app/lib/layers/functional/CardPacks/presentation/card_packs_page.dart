import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/CardPacks/domain/entities/card_pack_session.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/entities/pack_rules.dart';
import 'package:amiludo/layers/functional/CardPacks/presentation/board_view.dart';
import 'package:amiludo/layers/functional/CardPacks/presentation/cubit/card_pack_cubit.dart';
import 'package:amiludo/layers/functional/CardPacks/presentation/pack_setup_view.dart';
import 'package:amiludo/layers/functional/CardPacks/presentation/player_view.dart';
import 'package:amiludo/layers/functional/CardPacks/presentation/sheet_view.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class CardPacksPage extends StatefulWidget {
  const CardPacksPage({super.key, required this.templates, this.onSave});

  final List<GameTemplate> templates;
  final Future<void> Function(GameCharacter character)? onSave;

  @override
  State<CardPacksPage> createState() => _CardPacksPageState();
}

class _CardPacksPageState extends State<CardPacksPage> {
  int tab = 0, player = 0;
  late final bool resumed = context.read<CardPackCubit>().state != null;

  @override
  void initState() {
    super.initState();
    if (resumed) tab = 1;
  }

  RulesIssue? start({
    required GameTemplate template,
    required PackRules rules,
    required List<PoolDeck> pool,
    required List<String> names,
    required bool free,
  }) {
    final now = DateTime.now().microsecondsSinceEpoch;
    final issue = context.read<CardPackCubit>().begin(
      id: newId(),
      template: template.name,
      rules: rules,
      pool: pool,
      names: names,
      seed: now,
      now: now ~/ 1000,
      free: free,
    );
    if (issue == null) {
      setState(() {
        tab = 1;
        player = 0;
      });
    }
    return issue;
  }

  Widget tabs(bool active) {
    final l = context.l10n;
    final narrow = MediaQuery.sizeOf(context).width < 520;
    ButtonSegment<int> segment(int v, String label, IconData icon, bool on) =>
        ButtonSegment(
          value: v,
          enabled: on,
          tooltip: label,
          icon: narrow ? Icon(icon, semanticLabel: label) : null,
          label: narrow ? null : Text(label),
        );
    return SegmentedButton<int>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        minimumSize: const Size(Targets.minimum, Targets.minimum),
        visualDensity: VisualDensity.compact,
      ),
      segments: [
        segment(0, l.cpTabSetup, Icons.tune, true),
        segment(1, l.cpTabPlay, Icons.style_outlined, active),
        segment(2, l.cpTabBoard, Icons.leaderboard_outlined, active),
      ],
      selected: {tab},
      onSelectionChanged: (v) => setState(() => tab = v.first),
    );
  }

  Widget setup(CardPackSession? session) {
    if (session == null) {
      return widget.templates.isEmpty
          ? Text(context.l10n.cpNoTemplate)
          : PackSetupView(templates: widget.templates, onStart: start);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(session.template, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: Space.lg),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(Targets.minimum),
          ),
          onPressed: () async {
            await context.read<CardPackCubit>().end();
            if (mounted) setState(() => tab = 0);
          },
          child: Text(context.l10n.cpEnd),
        ),
      ],
    );
  }

  Widget play(CardPackSession session) {
    final index = player.clamp(0, session.players.length - 1);
    final current = session.players[index];
    final cubit = context.read<CardPackCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: Space.sm,
          children: [
            for (var i = 0; i < session.players.length; i++)
              ChoiceChip(
                label: Text(session.players[i].name),
                selected: i == index,
                onSelected: (_) => setState(() => player = i),
              ),
          ],
        ),
        const SizedBox(height: Space.lg),
        if (current.validated)
          SheetView(
            key: ValueKey('sheet-$index'),
            player: current,
            template: session.template,
            onSave: widget.onSave,
          )
        else ...[
          Text(
            context.l10n.cpPassPhone(current.name),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: Space.md),
          PlayerView(session: session, index: index, cubit: cubit),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<CardPackCubit>().state;
    final shown = session == null ? 0 : tab;
    return FullPage(
      title: context.l10n.toolCardPacksTitle,
      tool: 'card-packs',
      immersive: true,
      actions: [tabs(session != null)],
      child: Padding(
        padding: const EdgeInsets.only(bottom: Space.xl),
        child: switch (shown) {
          1 => play(session!),
          2 => BoardView(session: session!),
          _ => setup(session),
        },
      ),
    );
  }
}
