import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/secret_vote.dart';
import 'package:amiludo/layers/functional/Random/presentation/vote_phases.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

enum VotePhase { setup, gate, ballot, result }

class VoteTool extends StatefulWidget {
  const VoteTool({super.key});

  @override
  State<VoteTool> createState() => _VoteToolState();
}

class _VoteToolState extends State<VoteTool> {
  final tool = toolThemeFor('vote');
  final _question = TextEditingController();
  final _choices = TextEditingController();
  VotePhase phase = VotePhase.setup;
  SecretVote? vote;
  int voters = 4;
  int? selected;

  @override
  void dispose() {
    _question.dispose();
    _choices.dispose();
    super.dispose();
  }

  void _start() {
    final choices = parseChoices(_choices.text);
    final question = _question.text.trim();
    if (question.isEmpty || choices.length < 2) {
      notify(context, context.l10n.voteNeedTwo);
      return;
    }
    tool.signal();
    setState(() {
      vote = SecretVote(question: question, choices: choices, voters: voters);
      phase = VotePhase.gate;
    });
  }

  void _continue() => setState(
    () => phase = vote!.closed ? VotePhase.result : VotePhase.ballot,
  );

  void _cast() {
    tool.signal();
    setState(() {
      vote = vote!.cast(selected!);
      selected = null;
      phase = VotePhase.gate;
    });
  }

  void _again() => setState(() {
    vote = null;
    phase = VotePhase.setup;
  });

  Widget _voters() {
    final l = context.l10n;
    return Row(
      children: [
        Expanded(
          child: Text(
            l.voteVoters,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          tooltip: l.voteFewer,
          onPressed: voters > minVoters ? () => setState(() => voters--) : null,
          icon: const DeckIcon(Icons.remove),
        ),
        Semantics(
          liveRegion: true,
          child: SizedBox(
            width: Space.xxl,
            child: Text(
              '$voters',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        IconButton(
          tooltip: l.voteMore,
          onPressed: voters < maxVoters ? () => setState(() => voters++) : null,
          icon: const DeckIcon(Icons.add),
        ),
      ],
    );
  }

  Widget _setup() {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _question,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(labelText: l.voteQuestion),
        ),
        const SizedBox(height: Space.lg),
        TextField(
          controller: _choices,
          minLines: 2,
          maxLines: 5,
          decoration: InputDecoration(labelText: l.voteChoices),
        ),
        const SizedBox(height: Space.lg),
        _voters(),
        const SizedBox(height: Space.xl),
        FilledButton(onPressed: _start, child: Text(l.voteStart)),
      ],
    );
  }

  Widget _body() => switch (phase) {
    VotePhase.setup => _setup(),
    VotePhase.gate => VoteGate(vote: vote!, onContinue: _continue),
    VotePhase.ballot => VoteBallot(
      vote: vote!,
      selected: selected,
      onSelect: (i) => setState(() => selected = i),
      onCast: _cast,
    ),
    VotePhase.result => VoteResult(vote: vote!, onAgain: _again),
  };

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: AnimatedSwitcher(
        duration: tool.duration(context),
        child: KeyedSubtree(
          key: ValueKey('$phase-${vote?.ballots.length}'),
          child: _body(),
        ),
      ),
    ),
  );
}
