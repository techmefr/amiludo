import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

class EveningRsvpLists extends StatelessWidget {
  const EveningRsvpLists({super.key, required this.evening});

  final Evening evening;

  @override
  Widget build(BuildContext context) {
    final groups = [
      (
        tr(context, 'Inscrits', 'Going'),
        Icons.check_circle_outline,
        evening.going,
      ),
      (
        tr(context, 'Liste d’attente', 'Waiting list'),
        Icons.hourglass_empty,
        evening.waitlist,
      ),
      (tr(context, 'Peut-être', 'Maybe'), Icons.help_outline, evening.maybe),
      (
        tr(context, 'Ne viennent pas', 'Not coming'),
        Icons.cancel_outlined,
        evening.declined,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeading(tr(context, 'Inscrits', 'Going')),
        ListTile(
          leading: const Icon(Icons.star),
          title: Text(evening.hostName.isEmpty ? '?' : evening.hostName),
          subtitle: Text(tr(context, 'Organise', 'Hosting')),
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
