import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/functional/Evenings/presentation/cubit/evenings_cubit.dart';
import 'package:amiludo/layers/functional/Evenings/presentation/evening_texts.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class EveningsScreen extends StatelessWidget {
  const EveningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final evenings = [...context.watch<EveningsCubit>().state.evenings]
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final now = DateTime.now().toUtc().subtract(const Duration(hours: 6));
    final upcoming = evenings.where((e) => e.startsAt.isAfter(now)).toList();
    final past = evenings.where((e) => !e.startsAt.isAfter(now)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => context.go('/evenings/edit/new'),
              icon: const Icon(Icons.event_available),
              label: Text(context.l10n.eveningsPlanANight),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/join'),
              icon: const Icon(Icons.login),
              label: Text(context.l10n.eveningsIHaveACode),
            ),
          ],
        ),
        SectionHeading(context.l10n.eveningsUpcoming),
        if (upcoming.isEmpty)
          EmptyPanel(
            icon: Icons.event_outlined,
            title: context.l10n.eveningsNoNightPlanned,
            message: context.l10n.eveningsPickADateInviteBy,
          ),
        for (final e in upcoming) _EveningTile(evening: e),
        if (past.isNotEmpty) ...[
          SectionHeading(context.l10n.eveningsPast),
          for (final e in past.reversed) _EveningTile(evening: e),
        ],
      ],
    );
  }
}

class _EveningTile extends StatelessWidget {
  const _EveningTile({required this.evening});

  final Evening evening;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DeckPanel(
      padding: 8,
      child: ListTile(
        leading: Icon(evening.mine ? Icons.star_outline : Icons.mail_outline),
        title: Text(evening.title),
        subtitle: Text(
          [
            eveningWhen(context, evening.startsAt),
            if (evening.place.isNotEmpty) evening.place,
            seatsLine(context, evening),
          ].join('\n'),
        ),
        trailing: const DeckIcon(Icons.chevron_right),
        onTap: () => context.go('/evenings/${evening.id}'),
      ),
    ),
  );
}
