import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/impostor_round.dart';
import 'package:amiludo/layers/functional/Random/presentation/count_stepper.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

enum ImpostorPhase { setup, gate, role, result }

class ImpostorTool extends StatefulWidget {
  const ImpostorTool({super.key, this.random});
  final Random? random;

  @override
  State<ImpostorTool> createState() => _ImpostorToolState();
}

class _ImpostorToolState extends State<ImpostorTool> {
  final tool = toolThemeFor('impostor');
  final _word = TextEditingController();
  late final Random _random = widget.random ?? Random.secure();
  ImpostorPhase phase = ImpostorPhase.setup;
  ImpostorRound? round;
  int players = 5;

  @override
  void dispose() {
    _word.dispose();
    super.dispose();
  }

  void _start() {
    if (_word.text.trim().isEmpty) {
      notify(context, context.l10n.impostorNeedWord);
      return;
    }
    tool.signal();
    setState(() {
      round = ImpostorRound.deal(_word.text, players, _random);
      phase = ImpostorPhase.gate;
    });
  }

  void _show() => setState(() => phase = ImpostorPhase.role);

  void _hide() => setState(() {
    round = round!.advance();
    phase = ImpostorPhase.gate;
  });

  void _again() => setState(() {
    _word.clear();
    round = null;
    phase = ImpostorPhase.setup;
  });

  Widget _setup() {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.impostorHint),
        const SizedBox(height: Space.lg),
        TextField(
          controller: _word,
          obscureText: true,
          decoration: InputDecoration(labelText: l.impostorWord),
        ),
        const SizedBox(height: Space.lg),
        CountStepper(
          label: l.impostorPlayers,
          value: players,
          minimum: minImpostorPlayers,
          maximum: maxImpostorPlayers,
          lessTooltip: l.impostorFewer,
          moreTooltip: l.impostorMore,
          onChanged: (v) => setState(() => players = v),
        ),
        const SizedBox(height: Space.xl),
        FilledButton(onPressed: _start, child: Text(l.impostorStart)),
      ],
    );
  }

  Widget _gate() {
    final l = context.l10n;
    final current = round!;
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        const DeckIcon(Icons.visibility_off_outlined, size: 56),
        const SizedBox(height: Space.lg),
        Semantics(
          liveRegion: true,
          child: Text(
            current.done
                ? l.impostorAllSeen
                : l.impostorTurn(current.turn, current.players),
            style: text.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: Space.sm),
        if (!current.done) Text(l.impostorPass, textAlign: TextAlign.center),
        const SizedBox(height: Space.xl),
        FilledButton(
          onPressed: current.done
              ? () => setState(() => phase = ImpostorPhase.result)
              : _show,
          child: Text(current.done ? l.impostorReveal : l.impostorShow),
        ),
      ],
    );
  }

  Widget _role() {
    final l = context.l10n;
    final current = round!;
    final text = Theme.of(context).textTheme;
    final surface = tool.surface(context);
    return Column(
      children: [
        Text(l.impostorTurn(current.turn, current.players)),
        const SizedBox(height: Space.lg),
        if (!current.holderIsImpostor)
          Text(l.impostorWordIs, style: text.titleMedium),
        Semantics(
          liveRegion: true,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: Space.lg),
            padding: const EdgeInsets.all(Space.xl),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(Radii.lg),
            ),
            child: Text(
              current.holderIsImpostor ? l.impostorYouAre : current.word,
              textAlign: TextAlign.center,
              style: text.headlineMedium?.copyWith(color: tool.ink(surface)),
            ),
          ),
        ),
        FilledButton(onPressed: _hide, child: Text(l.impostorHide)),
      ],
    );
  }

  Widget _result() {
    final l = context.l10n;
    final current = round!;
    return Column(
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            l.impostorWas(current.impostor + 1),
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: Space.sm),
        Text(current.word),
        const SizedBox(height: Space.xl),
        OutlinedButton(onPressed: _again, child: Text(l.impostorAgain)),
      ],
    );
  }

  Widget _body() => switch (phase) {
    ImpostorPhase.setup => _setup(),
    ImpostorPhase.gate => _gate(),
    ImpostorPhase.role => _role(),
    ImpostorPhase.result => _result(),
  };

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: AnimatedSwitcher(
        duration: tool.duration(context),
        child: KeyedSubtree(
          key: ValueKey('$phase-${round?.seen}'),
          child: _body(),
        ),
      ),
    ),
  );
}
