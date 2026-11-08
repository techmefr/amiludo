import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/secret_vote.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class VoteGate extends StatelessWidget {
  const VoteGate({super.key, required this.vote, required this.onContinue});
  final SecretVote vote;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final closed = vote.closed;
    return Column(
      children: [
        const DeckIcon(Icons.lock_outline, size: 56),
        const SizedBox(height: Space.lg),
        Semantics(
          liveRegion: true,
          child: Text(
            closed ? l.voteDone : l.voteTurn(vote.turn, vote.voters),
            style: text.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: Space.sm),
        if (!closed) Text(l.votePass, textAlign: TextAlign.center),
        const SizedBox(height: Space.xl),
        FilledButton(
          onPressed: onContinue,
          child: Text(closed ? l.voteReveal : l.voteReady),
        ),
      ],
    );
  }
}

class VoteBallot extends StatelessWidget {
  const VoteBallot({
    super.key,
    required this.vote,
    required this.selected,
    required this.onSelect,
    required this.onCast,
  });
  final SecretVote vote;
  final int? selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onCast;

  Widget _choice(int i) {
    final label = Text(vote.choices[i]);
    final style = OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(Targets.minimum),
    );
    if (selected != i) {
      return OutlinedButton(
        onPressed: () => onSelect(i),
        style: style,
        child: label,
      );
    }
    return FilledButton.tonalIcon(
      onPressed: () => onSelect(i),
      style: style,
      icon: const DeckIcon(Icons.check),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.voteTurn(vote.turn, vote.voters), style: text.labelLarge),
        const SizedBox(height: Space.xs),
        Text(vote.question, style: text.headlineSmall),
        const SizedBox(height: Space.lg),
        for (var i = 0; i < vote.choices.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: Semantics(selected: selected == i, child: _choice(i)),
          ),
        const SizedBox(height: Space.lg),
        FilledButton(
          onPressed: selected == null ? null : onCast,
          child: Text(l.voteCast),
        ),
      ],
    );
  }
}

class VoteResult extends StatelessWidget {
  const VoteResult({super.key, required this.vote, required this.onAgain});
  final SecretVote vote;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final tool = toolThemeFor('vote');
    final ink = tool.ink(tool.surface(context));
    final tally = vote.tally;
    final best = tally.fold(1, (a, b) => a > b ? a : b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.voteResult, style: text.labelLarge),
        Text(vote.question, style: text.headlineSmall),
        if (vote.tied)
          Padding(
            padding: const EdgeInsets.only(top: Space.sm),
            child: Text(l.voteTie, style: text.titleMedium),
          ),
        const SizedBox(height: Space.lg),
        for (var i = 0; i < vote.choices.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            child: Semantics(
              label: '${vote.choices[i]}, ${l.voteCount(tally[i])}',
              excludeSemantics: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vote.choices[i],
                          style: vote.winners.contains(i)
                              ? text.titleMedium
                              : text.bodyLarge,
                        ),
                      ),
                      Text(l.voteCount(tally[i])),
                    ],
                  ),
                  const SizedBox(height: Space.xs),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: tally[i] / best),
                    duration: tool.duration(context) * 2,
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(Radii.sm),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: Space.md,
                        color: vote.winners.contains(i)
                            ? ink
                            : ink.withValues(alpha: .45),
                        backgroundColor: ink.withValues(alpha: .12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: Space.lg),
        OutlinedButton(onPressed: onAgain, child: Text(l.voteAgain)),
      ],
    );
  }
}
