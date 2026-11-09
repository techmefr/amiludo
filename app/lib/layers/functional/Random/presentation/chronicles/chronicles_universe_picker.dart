import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/chronicles_cubit.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_tile.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

class ChroniclesUniversePicker extends StatelessWidget {
  const ChroniclesUniversePicker({super.key, required this.data});
  final ChroniclesData data;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DeckHeading(
        eyebrow: context.l10n.chroniclesTitle,
        title: context.l10n.chroniclesChooseUniverse,
        subtitle: context.l10n.chroniclesSubtitle,
      ),
      ResponsiveGrid(
        minimumWidth: 280,
        children: [
          for (final u in data.universes)
            DeckTile(
              key: ValueKey('universe-${u.id}'),
              icon: Icons.auto_stories_outlined,
              title: u.name,
              onTap: () => context.read<ChroniclesCubit>().start(u.id),
            ),
        ],
      ),
    ],
  );
}
