import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class EveningRsvpLists extends StatelessWidget {
  const EveningRsvpLists({super.key, required this.evening});

  final Evening evening;

  @override
  Widget build(BuildContext context) {
    final groups = [
      (context.l10n.eveningsGoing, Icons.check_circle_outline, evening.going),
      (
        context.l10n.eveningsWaitingList,
        Icons.hourglass_empty,
        evening.waitlist,
      ),
      (context.l10n.eveningsMaybe, Icons.help_outline, evening.maybe),
      (context.l10n.eveningsNotComing, Icons.cancel_outlined, evening.declined),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeading(context.l10n.eveningsGoing),
        ListTile(
          leading: const Icon(Icons.star),
          title: Text(evening.hostName.isEmpty ? '?' : evening.hostName),
          subtitle: Text(context.l10n.eveningsHosting),
        ),
        for (final (title, icon, people) in groups)
          if (people.isNotEmpty) ...[
            if (title != groups.first.$1) SectionHeading(title),
            for (final (index, rsvp) in people.indexed)
              ListTile(
                leading: Icon(icon),
                title: Text(rsvp.name),
                trailing: icon == Icons.hourglass_empty
                    ? Text('#${index + 1}')
                    : null,
              ),
          ],
      ],
    );
  }
}
