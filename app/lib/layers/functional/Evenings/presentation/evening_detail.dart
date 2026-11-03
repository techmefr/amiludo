import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/functional/Evenings/presentation/cubit/evenings_cubit.dart';
import 'package:amiludo/layers/functional/Evenings/presentation/evening_host_tools.dart';
import 'package:amiludo/layers/functional/Evenings/presentation/evening_rsvp_lists.dart';
import 'package:amiludo/layers/functional/Evenings/presentation/evening_texts.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';

class EveningDetail extends StatelessWidget {
  const EveningDetail({super.key, required this.id});

  final String id;

  Future<void> _remove(BuildContext context, Evening evening) async {
    final ok = await confirm(
      context,
      tr(context, 'Retirer la soirée ?', 'Remove this night?'),
      evening.mine
          ? tr(
              context,
              'Les inscriptions seront perdues.',
              'Sign-ups will be lost.',
            )
          : tr(
              context,
              'Elle disparaît de votre liste.',
              'It leaves your list.',
            ),
    );
    if (!ok || !context.mounted) return;
    await runEveningAction(
      context,
      () => context.read<EveningsCubit>().remove(evening.id),
    );
    if (context.mounted) context.go('/evenings');
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<EveningsCubit>();
    final evening = cubit.evening(id);
    return FullPage(
      title: evening?.title ?? tr(context, 'Soirée', 'Game night'),
      fallback: '/evenings',
      actions: [
        if (evening != null && evening.published)
          IconButton(
            tooltip: tr(context, 'Actualiser', 'Refresh'),
            onPressed: () =>
                runEveningAction(context, () => cubit.fetch(evening.code)),
            icon: const Icon(Icons.refresh),
          ),
        if (evening != null && evening.mine)
          IconButton(
            tooltip: tr(context, 'Modifier', 'Edit'),
            onPressed: () => context.go('/evenings/edit/${evening.id}'),
            icon: const Icon(Icons.edit_outlined),
          ),
        if (evening != null)
          IconButton(
            tooltip: tr(context, 'Retirer', 'Remove'),
            onPressed: () => _remove(context, evening),
            icon: const Icon(Icons.delete_outline),
          ),
      ],
      child: evening == null
          ? EmptyPanel(
              title: tr(context, 'Soirée introuvable', 'Night not found'),
              message: tr(context, 'Elle a été retirée.', 'It was removed.'),
            )
          : EveningBody(evening: evening),
    );
  }
}

class EveningBody extends StatelessWidget {
  const EveningBody({super.key, required this.evening});

  final Evening evening;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      DeckPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eveningWhen(context, evening.startsAt),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (evening.place.isNotEmpty) Text(evening.place),
            const SizedBox(height: 8),
            Text(seatsLine(context, evening)),
            if (evening.gameNames.isNotEmpty)
              Text(
                tr(
                  context,
                  'Au programme : ${evening.gameNames.join(', ')}',
                  'On the menu: ${evening.gameNames.join(', ')}',
                ),
              ),
          ],
        ),
      ),
      if (evening.mine) ...[
        const SizedBox(height: 16),
        EveningInvite(evening: evening),
      ] else
        _MyAnswer(evening: evening),
      EveningRsvpLists(evening: evening),
      if (evening.mine) FriendAnswers(evening: evening),
    ],
  );
}

class _MyAnswer extends StatelessWidget {
  const _MyAnswer({required this.evening});

  final Evening evening;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<EveningsCubit>();
    final mine = cubit.myId == null ? null : evening.rsvpOf(cubit.myId!);
    final waiting = mine != null && evening.waitlist.contains(mine);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeading(tr(context, 'Votre réponse', 'Your answer')),
        if (evening.published && !cubit.signedIn)
          OutlinedButton(
            onPressed: () => context.go('/account'),
            child: Text(
              tr(context, 'Se connecter pour s’inscrire', 'Sign in to sign up'),
            ),
          )
        else
          SegmentedButton<RsvpAnswer>(
            emptySelectionAllowed: true,
            segments: [
              for (final answer in RsvpAnswer.values)
                ButtonSegment(
                  value: answer,
                  label: Text(answerLabel(context, answer)),
                ),
            ],
            selected: {?mine?.answer},
            onSelectionChanged: (picked) {
              if (picked.isEmpty) return;
              runEveningAction(
                context,
                () => cubit.answer(evening.id, picked.first),
              );
            },
          ),
        if (waiting)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              tr(
                context,
                'Complet : vous êtes sur liste d’attente.',
                'Full: you are on the waiting list.',
              ),
            ),
          ),
      ],
    );
  }
}
